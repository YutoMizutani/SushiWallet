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
    func createPeerGroup() -> Single<PeerGroup>
    func generateNewHDWallet() -> Single<(hdWallet: HDWallet, index: UInt32)>
    func loadHDWallet() -> Single<(hdWallet: HDWallet, index: UInt32)>
    func updateIndex(_ index: UInt32) -> Single<Void>
    func getBalance(_ address: Address) -> Single<Decimal>
    func getTransactions(_ address: Address) -> Single<[Payment]>
    func getUsedAddresses(_ wallet: HDWallet) -> Single<[Address]>
    func getAllBalances(_ wallet: HDWallet) -> Single<[Decimal]>
    func getAllTransactions(_ wallet: HDWallet) -> Single<[Payment]>
    func fetchBalance(_ address: BitcoinAddress) -> Single<Decimal>
    func fetchTransactions(_ address: BitcoinAddress) -> Single<Transactions>
    func fetchInsight(_ address: BitcoinAddress) -> Single<UnspentOutput?>
    func fetchInsight(_ addressess: [BitcoinAddress]) -> Single<UnspentOutputs>
}

struct BCHTestnetHDWalletUseCase: WalletUseCaseCore, HDWalletUseCase {
    fileprivate let network: Network = .testnet
    private let dataStore = WalletUserDefaultDataStore()
    private let balanceAPI = BitpayBalanceAPI(.bchTestnet)
    private let transactionsAPI = BitpayTransactionsAPI(.bchTestnet)
    private let unspentOutputsAPI = BitpayUnspentOutputsAPI(.bchTestnet)

    /// Create a new peer group
    func createPeerGroup() -> Single<PeerGroup> {
        return Single.create(subscribe: { single -> Disposable in
            let blockStore: BlockStore = try! SQLiteBlockStore.default()
            let blockChain: BlockChain = BlockChain(network: self.network, blockStore: blockStore)
            let peerGroup: PeerGroup = PeerGroup(blockChain: blockChain)
            single(.success(peerGroup))

            return Disposables.create()
        })
    }

    /// Generate a new HD wallet to data store
    func generateNewHDWallet() -> Single<(hdWallet: HDWallet, index: UInt32)> {
        let privateKey = PrivateKey(network: network)
        return generateHDWallet(from: privateKey)
            .flatMap { hdWallet in
                let index: UInt32 = 0
                return Single.zip(self.saveHDDWallet(privateKey), self.updateIndex(index))
                    .map { _ in (hdWallet, index) }
            }
    }

    /// Save the HD wallet using private key to data store
    private func saveHDDWallet(_ privateKey: PrivateKey) -> Single<Void> {
        return Single.create(subscribe: { single -> Disposable in
            self.dataStore.setPrivateKeyWIF(privateKey.toWIF())
            single(.success(()))

            return Disposables.create()
        })
    }

    /// Load the HD wallet from data store
    func loadHDWallet() -> Single<(hdWallet: HDWallet, index: UInt32)> {
        guard
            let wif: String = dataStore.getPrivateKeyWIF(),
            let privateKey: PrivateKey = try? PrivateKey(wif: wif)
        else {
            return Single.error(RxError.noElements)
        }
            
        return Single.zip(generateHDWallet(from: privateKey), getCurrentIndexOrGenerateIfEmpty())
            .flatMap { wallet, index in
                self.updateIndex(index)
                    .map { (wallet, index) }
            }
    }

    /// Generate HD wallet from inputted private key
    private func generateHDWallet(from privateKey: PrivateKey) -> Single<HDWallet> {
        return Single.create(subscribe: { single -> Disposable in
            let privateKey = privateKey
            let wallet = HDWallet(seed: privateKey.raw, network: self.network)
            single(.success(wallet))

            return Disposables.create()
        })
    }

    /// Update using index to data store
    func updateIndex(_ index: UInt32) -> Single<Void> {
        return getMaxIndex().asObservable()
            .materialize().take(1)
            .flatMapLatest { e -> Single<Void> in
                switch e {
                case .next(let max):
                    if index > max {
                        self.dataStore.setMaxIndex(index)
                    }
                    self.dataStore.setCurrentIndex(index)
                    return Single.just(())
                case .error:
                    self.dataStore.setMaxIndex(index)
                    self.dataStore.setCurrentIndex(index)
                    return Single.just(())
                case .completed:
                    fatalError()
                }
            }
            .take(1).asSingle()
    }

    /// Get used current index from data store
    private func getCurrentIndexOrGenerateIfEmpty() -> Single<UInt32> {
        let index = self.dataStore.getCurrentIndex() ?? 0
        return updateIndex(index)
            .map { index }
    }

    /// Get used max index from data store
    private func getMaxIndex() -> Single<UInt32> {
        return Single.create(subscribe: { single -> Disposable in
            if let index = self.dataStore.getMaxIndex() {
                single(.success(index))
            } else {
                single(.error(RxError.noElements))
            }

            return Disposables.create()
        })
    }

    /// Get balance from inputted address
    func getBalance(_ address: Address) -> Single<Decimal> {
        let blockStore = try! SQLiteBlockStore.default()
        return Single.just(try! blockStore.calculateBalance(address: address))
            .map { Decimal($0) / Decimal(100000000) }
    }

    /// Get transactions from inputted address
    func getTransactions(_ address: Address) -> Single<[Payment]> {
        let blockStore = try! SQLiteBlockStore.default()
        return Single.just(try! blockStore.transactions(address: address))
    }

    /// Get used all addresses in the HD wallet
    func getUsedAddresses(_ wallet: HDWallet) -> Single<[Address]> {
        return getMaxIndex()
            .map { (0..<$0).compactMap { try? wallet.receiveAddress(index: $0) } }
    }

    /// Get all balances from all addresses in the HD wallet
    func getAllBalances(_ wallet: HDWallet) -> Single<[Decimal]> {
        return getUsedAddresses(wallet)
            .flatMap { Single.zip($0.map { self.getBalance($0) }) }
    }

    /// Get flatten all transactions from all addresses in the HD wallet
    func getAllTransactions(_ wallet: HDWallet) -> Single<[Payment]> {
        return getUsedAddresses(wallet)
            .flatMap { Single.zip($0.map { self.getTransactions($0) }) }
            .map { $0.flatMap { $0 } }
            .map { Array(Set($0)) }
    }

    func fetchBalance(_ address: BitcoinAddress) -> Single<Decimal> {
        return balanceAPI.request(address)
    }

    func fetchTransactions(_ address: BitcoinAddress) -> Single<Transactions> {
        return transactionsAPI.request(address)
    }

    func fetchInsight(_ address: BitcoinAddress) -> Single<UnspentOutput?> {
        return unspentOutputsAPI.request(address).map { $0.first }
    }

    func fetchInsight(_ addressess: [BitcoinAddress]) -> Single<UnspentOutputs> {
        return unspentOutputsAPI.request(addressess)
    }
}
