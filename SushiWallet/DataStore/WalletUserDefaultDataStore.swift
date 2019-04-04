//
//  WalletUserDefaultDataStore.swift
//  SushiWallet
//
//  Created by ym on 2019/04/05.
//  Copyright © 2019 Yuto Mizutani. All rights reserved.
//

import Foundation

struct WalletUserDefaultDataStore {
    private let wifKey = "wif"

    func setPrivateKeyWIF(_ wif: String) {
        UserDefaults.standard.set(wif, forKey: wifKey)
    }

    func getPrivateKeyWIF() -> String? {
        return UserDefaults.standard.string(forKey: wifKey)
    }
}
