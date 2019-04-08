//
//  TransactionsResponse.swift
//  SushiWallet
//
//  Created by ym on 2019/04/08.
//  Copyright © 2019 Yuto Mizutani. All rights reserved.
//

import Foundation

struct TransactionsResponse: Codable, EntityTranslatable {
    typealias EntityType = Transactions

    let pagesTotal: Int
    let txs: [Tx]

    struct Tx: Codable, EntityTranslatable {
        typealias EntityType = Transaction

        let txid: String
        let version: Int
        let locktime: Int
        let vin: [Vin]
        let valueIn: Decimal
        let fees: Decimal
        let vout: [Vout]
        let blockhash: String
        let blockheight: Int
        let confirmations: Int
        let time: Int
        let blocktime: Int
        let valueOut: Decimal
        let size: Int

        struct Vin: Codable, EntityTranslatable {
            typealias EntityType = TransactionInput

            let txid: String
            let vout: Int
            let sequence: Int
            let n: Int
            let scriptSig: ScriptSig
            let addr: String
            let valueSat: Int
            let value: Decimal
            let doubleSpentTxID: String?
            let isConfirmed: String?
            let confirmations: String?
            let unconfirmedInput: String?

            struct ScriptSig: Codable {
                let hex: String
                let asm: String
            }

            func toEntity() -> TransactionInput {
                return TransactionInput(n: n,
                                        address: addr,
                                        value: value)
            }
        }

        struct Vout: Codable, EntityTranslatable {
            typealias EntityType = TransactionOutput

            let value: String
            let n: Int
            let scriptPubKey: ScriptPubKey
            let spentTxId: String?
            let spentIndex: Int?
            let spentHeight: Int?

            struct ScriptPubKey: Codable {
                let hex: String
                let asm: String
                let addresses: [String]
                let type: String
            }

            func toEntity() -> TransactionOutput {
                return TransactionOutput(n: n,
                                         addresses: scriptPubKey.addresses,
                                         value: Decimal(Double(value)!))
            }
        }

        func toEntity() -> Transaction {
            return Transaction(txid: txid,
                               hash: blockhash,
                               date: Date(timeIntervalSince1970: TimeInterval(time)),
                               block: blockheight,
                               confirmations: confirmations,
                               inputs: vin.map { $0.toEntity() },
                               outputs: vout.map { $0.toEntity() })
        }
    }

    func toEntity() -> Transactions {
        return txs.map { $0.toEntity() }
    }
}
