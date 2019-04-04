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
    static let succeededToRegenerate: String = "再生成しました🍣"
    static let succeededToCopy: String = "コピーしました🍣"
}

class ViewController: UIViewController {
    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var zoomButton: UIButton!
    @IBOutlet weak var addressTextView: UITextView!
    @IBOutlet weak var regenerateButton: UIButton!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var tableView: TransactionHistoryTableView!

    private var imageHeightConstraint: NSLayoutConstraint!
    private let constraints: (min: CGFloat, max: CGFloat) = (100, 300)

    private var wallet: PublishRelay<Wallet> = PublishRelay()

    private let useCase: WalletUseCase = BCHTestnetWalletUseCase()
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
            .flatMapLatest { [unowned self] in self.useCase.loadCurrentWallet().asObservable().materialize().take(1) }
            .flatMapLatest { [unowned self] event -> Single<Wallet> in
                switch event {
                case .next(let value):
                    return Single.just(value)
                case .error:
                    return self.useCase.generateNewWallet()
                        .flatMap { [unowned self] wallet in self.useCase.saveCurrentWallet(wallet).map { wallet } }
                case .completed:
                    fatalError("Not allow complete")
                }
            }
            .subscribe(onNext: { [weak self] in
                self?.wallet.accept($0)
            })
            .disposed(by: disposeBag)

        let address = wallet.asObservable()
            .map { $0.publicKey.toCashaddr().description }
            .map { BitcoinAddress($0) }
            .share(replay: 1)

        address
            .map { $0.generateQRCode() }
            .unwrap()
            .bind(to: qrImageView.rx.image)
            .disposed(by: disposeBag)

        address
            .map { $0.value }
            .bind(to: addressTextView.rx.text)
            .disposed(by: disposeBag)

        zoomButton.rx.tap.asDriver()
            .drive(onNext: { [unowned self] in
                self.toggleZoom()
            })
            .disposed(by: disposeBag)

        regenerateButton.rx.tap.asObservable()
            .flatMapLatest { [unowned self] in
                self.useCase.generateNewWallet()
                    .flatMap { [unowned self] wallet in self.useCase.saveCurrentWallet(wallet).map { wallet } }
            }
            .subscribe(onNext: { [weak self] in
                self?.regenerate($0)
            })
            .disposed(by: disposeBag)

        copyButton.rx.tap.asObservable()
            .withLatestFrom(address)
            .map { $0.value }
            .subscribe(onNext: { [weak self] in
                self?.copy($0)
            })
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

    /// Regenerate wallet address
    private func regenerate(_ wallet: Wallet) {
        self.wallet.accept(wallet)
        SVProgressHUD.showSuccess(withStatus: Text.succeededToRegenerate)
        SVProgressHUD.dismiss(withDelay: 0.4)
    }

    /// Copy wallet address
    private func copy(_ text: String) {
        UIPasteboard.general.string = text
        SVProgressHUD.showSuccess(withStatus: Text.succeededToCopy)
        SVProgressHUD.dismiss(withDelay: 0.4)
    }
}

