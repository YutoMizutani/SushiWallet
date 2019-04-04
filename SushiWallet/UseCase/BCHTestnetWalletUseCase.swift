//
//  BCHTestnetWalletUseCase.swift
//  SushiWallet
//
//  Created by ym on 2019/04/04.
//  Copyright © 2019 Yuto Mizutani. All rights reserved.
//

import BitcoinKit
import RxSwift

protocol WalletUseCase {
    func saveCurrentWallet(_ wallet: Wallet) -> Single<Void>
    func loadCurrentWallet() -> Single<Wallet>
    func generateNewWallet() -> Single<Wallet>
}

struct BCHTestnetWalletUseCase: WalletUseCase {
    private let dataStore = WalletUserDefaultDataStore()

    func saveCurrentWallet(_ wallet: Wallet) -> Single<Void> {
        return Single.create(subscribe: { single -> Disposable in
            self.dataStore.setPrivateKeyWIF(wallet.privateKey.toWIF())
            single(.success(()))

            return Disposables.create()
        })
    }

    func loadCurrentWallet() -> Single<Wallet> {
        return Single.create(subscribe: { single -> Disposable in
            guard
                let wif: String = self.dataStore.getPrivateKeyWIF(),
                let privateKey: PrivateKey = try? PrivateKey(wif: wif)
            else {
                single(.error(RxError.noElements))
                return Disposables.create()
            }

            let wallet: Wallet = Wallet(privateKey: privateKey)
            single(.success(wallet))

            return Disposables.create()
        })
    }

    func generateNewWallet() -> Single<Wallet> {
        return Single.create(subscribe: { single -> Disposable in
            let privateKey = PrivateKey(network: .testnet)
            let wallet = Wallet(privateKey: privateKey)
            single(.success(wallet))

            return Disposables.create()
        })
    }
}
