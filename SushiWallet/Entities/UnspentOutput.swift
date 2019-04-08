//
//  BCHTestnetResult.swift
//  SushiWallet
//
//  Created by ym on 2019/04/08.
//  Copyright © 2019 Yuto Mizutani. All rights reserved.
//

import Foundation

typealias UnspentOutputs = [UnspentOutput]

struct UnspentOutput {
    let address: String
    let txid: String
    let vout: Int
    let scriptPubKey: String
    let amount: Decimal
    let satoshis: Int
    let height: Int
    let confirmations: Int
}
