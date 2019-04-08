//
//  ViewController.swift
//  SushiWallet
//
//  Created by ym on 2019/04/03.
//  Copyright © 2019 Yuto Mizutani. All rights reserved.
//

import BitcoinKit
import RxCocoa
import RxSwift
import SVProgressHUD
import UIKit

struct Text {
    static let succeededToChange: String = "アドレスが変更されました🍣"
    static let succeededToCopy: String = "コピーしました🍣"
}

class ViewController: UIViewController {
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var zoomButton: UIButton!
    @IBOutlet weak var addressTextView: UITextView!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var tableView: TransactionHistoryTableView!

    private var imageHeightConstraint: NSLayoutConstraint!
    private let constraints: (min: CGFloat, max: CGFloat) = (100, 300)

    private var peerGroup: PeerGroup?
    private var hdWallet: PublishRelay<HDWallet> = PublishRelay()
    private var index: PublishRelay<UInt32> = PublishRelay()

    private let useCase: HDWalletUseCase = BCHTestnetHDWalletUseCase()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureBinding()
    }

    private func configureView() {
        imageHeightConstraint = NSLayoutConstraint(item: qrImageView!,
                                                   attribute: NSLayoutConstraint.Attribute.height,
                                                   relatedBy: NSLayoutConstraint.Relation.lessThanOrEqual,
                                                   toItem: nil,
                                                   attribute: NSLayoutConstraint.Attribute.height,
                                                   multiplier: 1,
                                                   constant: constraints.max)
        imageHeightConstraint.isActive = true
        view.layoutIfNeeded()
    }

    private func configureBinding() {
        rx.viewWillAppear.take(1).mapToVoid()
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
            .flatMapLatest { [unowned self] in self.useCase.loadHDWallet().asObservable().materialize().take(1) }
            .flatMapLatest { [unowned self] event -> Single<(hdWallet: HDWallet, index: UInt32)> in
                switch event {
                case .next(let value):
                    return Single.just(value)
                case .error:
                    return self.useCase.generateNewHDWallet()
                case .completed:
                    fatalError("Not allow complete")
                }
            }
            .subscribe(onNext: { [weak self] in
                self?.hdWallet.accept($0.hdWallet)
                self?.index.accept($0.index)
            })
            .disposed(by: disposeBag)

        let bitcoinAddress: Observable<BitcoinAddress> = Observable.combineLatest(hdWallet, index)
            .map { try? $0.0.receiveAddress(index: $0.1) }
            .unwrap()
            .map { BitcoinAddress($0.cashaddr) }
            .share(replay: 1)

        bitcoinAddress
            .map { $0.generateQRCode() }
            .unwrap()
            .bind(to: qrImageView.rx.image)
            .disposed(by: disposeBag)

        bitcoinAddress
            .map { $0.value }
            .bind(to: addressTextView.rx.text)
            .disposed(by: disposeBag)

        zoomButton.rx.tap.asDriver()
            .drive(onNext: { [unowned self] in
                self.toggleZoom()
            })
            .disposed(by: disposeBag)

        index
            .map { $0 > 0 }
            .bind(to: previousButton.rx.isEnabled)
            .disposed(by: disposeBag)
        previousButton.rx.tap.asObservable()
            .withLatestFrom(index)
            .filter { $0 > 0 }
            .map { $0 - 1 }
            .subscribe(onNext: { [weak self] in
                self?.index.accept($0)
            })
            .disposed(by: disposeBag)

        index
            .map { $0 < UInt32.max }
            .bind(to: nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
        nextButton.rx.tap.asObservable()
            .withLatestFrom(index)
            .filter { $0 < UInt32.max }
            .map { $0 + 1 }
            .subscribe(onNext: { [weak self] in
                self?.index.accept($0)
            })
            .disposed(by: disposeBag)

        index.asObservable().skip(1)
            .flatMapLatest { [unowned self] in self.useCase.updateIndex($0) }
            .subscribe(onNext: { [weak self] in
                self?.showSuccess(with: Text.succeededToChange)
            })
            .disposed(by: disposeBag)

        copyButton.rx.tap.asObservable()
            .withLatestFrom(bitcoinAddress)
            .map { $0.value }
            .subscribe(onNext: { [weak self] in
                self?.copy($0)
                self?.showSuccess(with: Text.succeededToCopy)
            })
            .disposed(by: disposeBag)

        let requestInterval: Float = 10
        let requestTimer: Observable<Float> = bitcoinAddress.mapToVoid()
            .flatMapLatest { Observable<Int>.interval(0.01, scheduler: ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global())) }
            .map { Float($0) * 0.01 }
            .map { $0.truncatingRemainder(dividingBy: requestInterval) }
            .share(replay: 1)

        requestTimer
            .map { $0 / requestInterval }
            .bind(to: progressView.rx.progress)
            .disposed(by: disposeBag)

        let requestTrigger: Observable<BitcoinAddress> = requestTimer.filter { $0 == 0 }.mapToVoid()
            .withLatestFrom(hdWallet)
            .withLatestFrom(index) { (wallet: $0, index: $1) }
            .map { try? $0.wallet.receiveAddress(index: $0.index) }.unwrap()
            .map { BitcoinAddress($0.cashaddr) }
            .share(replay: 1)

        requestTrigger
            .flatMapLatest { [unowned self] in self.useCase.fetchBalance($0) }
            .map { "Balance: \($0) BCH" }
            .bind(to: balanceLabel.rx.text)
            .disposed(by: disposeBag)

        requestTrigger
            .flatMapLatest { [unowned self] address in self.useCase.fetchTransactions(address).map { $0.map { ($0, address) } } }
            .map { [SectionOfTransactions(items: $0)] }
            .bind(to: tableView.rx.items(dataSource: tableView.configureDataSource))
            .disposed(by: disposeBag)
    }

    /// Toggle the height of QR code image
    private func toggleZoom() {
        qrImageView.removeConstraint(imageHeightConstraint)
        imageHeightConstraint.constant = imageHeightConstraint.constant == constraints.max ? constraints.min : constraints.max
        qrImageView.addConstraint(imageHeightConstraint)
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    /// Copy wallet address to clipboard
    private func copy(_ text: String) {
        UIPasteboard.general.string = text
    }

    /// Show success alert
    private func showSuccess(with status: String) {
        SVProgressHUD.showSuccess(withStatus: status)
        SVProgressHUD.dismiss(withDelay: 0.4)
    }
}

extension ViewController: PeerGroupDelegate {}
