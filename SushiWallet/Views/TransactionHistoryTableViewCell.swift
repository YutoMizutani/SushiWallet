//
//  TransactionHistoryTableViewCell.swift
//  SushiWallet
//
//  Created by ym on 2019/04/04.
//  Copyright © 2019 Yuto Mizutani. All rights reserved.
//

import BitcoinKit
import UIKit

class TransactionHistoryTableViewCell: UITableViewCell, NibLoadable {
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!

    func inject(_ payment: Payment) {
        fromLabel.text = payment.from.cashaddr
        toLabel.text = payment.to.cashaddr
        amountLabel.text = "\(Decimal(payment.amount) / Decimal(100000000))"
        print(payment.txid, payment.state, "\(Decimal(payment.amount) / Decimal(100000000))", payment.from, payment.to)
    }
}
