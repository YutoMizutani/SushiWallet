//
//  Transaction.swift
//  SushiWallet
//
//  Created by ym on 2019/04/08.
//  Copyright © 2019 Yuto Mizutani. All rights reserved.
//

import Foundation

typealias Transactions = [Transaction]

struct Transaction {
    let txid: String
    let hash: String
    let date: Date
    let block: Int
    let confirmations: Int
    let inputs: [TransactionInput]
    let outputs: [TransactionOutput]
}

protocol TransactionIO {
    var n: Int { get }
    var value: Decimal { get }
}

struct TransactionInput: TransactionIO {
    let n: Int
    let address: String
    let value: Decimal
}

struct TransactionOutput: TransactionIO {
    let n: Int
    let addresses: [String]
    let value: Decimal
}

extension Transaction {
    /// Rise and fall changes of the address
    func changes(_ address: BitcoinAddress) -> Decimal {
        let sumOfInputValue: Decimal = inputs.filter { $0.address == address.removedPrefix }.map { $0.value }.reduce(0, +)
        let sumOfOutputValue: Decimal = outputs.filter { $0.addresses.contains(address.removedPrefix) }.map { $0.value }.reduce(0, +)
        return sumOfOutputValue - sumOfInputValue
    }
}
