//
//  WalletUserDefaultDataStore.swift
//  SushiWallet
//
//  Created by ym on 2019/04/05.
//  Copyright © 2019 Yuto Mizutani. All rights reserved.
//

import Foundation

private enum Keys: String {
    case wif, index

    var key: String {
        return rawValue
    }
}

struct WalletUserDefaultDataStore {
    func setPrivateKeyWIF(_ wif: String) {
        UserDefaults.standard.set(wif, forKey: Keys.wif.key)
    }

    func getPrivateKeyWIF() -> String? {
        return UserDefaults.standard.string(forKey: Keys.wif.key)
    }

    func setCurrentIndex(_ index: UInt32) {
        UserDefaults.standard.set(Int(index), forKey: Keys.index.key)
    }

    func getCurrentIndex() -> UInt32? {
        guard UserDefaults.standard.object(forKey: Keys.index.key) != nil else { return nil }
        return UInt32(UserDefaults.standard.integer(forKey: Keys.index.key))
    }
}
