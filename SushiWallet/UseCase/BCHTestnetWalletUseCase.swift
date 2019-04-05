//
//  BCHTestnetWalletUseCase.swift
//  SushiWallet
//
//  Created by ym on 2019/04/04.
//  Copyright © 2019 Yuto Mizutani. All rights reserved.
//

import BitcoinKit
import RxSwift

private protocol WalletUseCaseCore {
    var network: Network { get }
}

protocol HDWalletUseCase {
    func generateNewHDWallet() -> Single<(hdWallet: HDWallet, index: UInt32)>
    func loadHDWallet() -> Single<(hdWallet: HDWallet, index: UInt32)>
    func updateIndex(_ index: UInt32) -> Single<Void>
}

struct BCHTestnetHDWalletUseCase: WalletUseCaseCore, HDWalletUseCase {
    fileprivate let network: Network = .testnet
    private let dataStore = WalletUserDefaultDataStore()

    func generateNewHDWallet() -> Single<(hdWallet: HDWallet, index: UInt32)> {
        let privateKey = PrivateKey(network: network)
        return generateHDWallet(from: privateKey)
            .flatMap { hdWallet in
                let index: UInt32 = 0
                return Single.zip(self.saveHDDWallet(privateKey), self.updateIndex(index))
                    .map { _ in (hdWallet, index) }
            }
    }

    private func saveHDDWallet(_ privateKey: PrivateKey) -> Single<Void> {
        return Single.create(subscribe: { single -> Disposable in
            self.dataStore.setPrivateKeyWIF(privateKey.toWIF())
            single(.success(()))

            return Disposables.create()
        })
    }

    func loadHDWallet() -> Single<(hdWallet: HDWallet, index: UInt32)> {
        guard
            let wif: String = dataStore.getPrivateKeyWIF(),
            let privateKey: PrivateKey = try? PrivateKey(wif: wif)
        else {
            return Single.error(RxError.noElements)
        }
            
        return Single.zip(generateHDWallet(from: privateKey), loadIndexOrGenerateIfEmpty())
            .flatMap { wallet, index in
                self.updateIndex(index)
                    .map { (wallet, index) }
            }
    }

    private func generateHDWallet(from privateKey: PrivateKey) -> Single<HDWallet> {
        return Single.create(subscribe: { single -> Disposable in
            let privateKey = privateKey
            let wallet = HDWallet(seed: privateKey.raw, network: self.network)
            single(.success(wallet))

            return Disposables.create()
        })
    }

    func updateIndex(_ index: UInt32) -> Single<Void> {
        return Single.create(subscribe: { single -> Disposable in
            self.dataStore.setCurrentIndex(index)
            single(.success(()))

            return Disposables.create()
        })
    }

    private func loadIndexOrGenerateIfEmpty() -> Single<UInt32> {
        return Single.create(subscribe: { single -> Disposable in
            let index = self.dataStore.getCurrentIndex() ?? 0
            single(.success(index))

            return Disposables.create()
        })
    }
}
