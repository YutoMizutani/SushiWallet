//
//  BitcoinKit+.swift
//  SushiWallet
//
//  Created by ym on 2019/04/07.
//  Copyright © 2019 Yuto Mizutani. All rights reserved.
//

import BitcoinKit

extension Payment: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(txid)
    }
}
