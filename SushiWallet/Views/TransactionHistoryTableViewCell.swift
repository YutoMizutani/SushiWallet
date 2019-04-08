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
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var inputLabel: UILabel!
    @IBOutlet weak var outputLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!

    func inject(_ transaction: Transaction, address: BitcoinAddress) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        let dateString = dateFormatter.string(from: transaction.date)
        dateLabel.text = dateString

        inputLabel.text = "Input: \(transaction.inputs.count)"
        outputLabel.text = "Output: \(transaction.outputs.count)"

        let changes: Decimal = transaction.changes(address)
        amountLabel.text = "\(changes)"
        switch changes {
        case 0:
            amountLabel.textColor = .black
        case ..<0:
            amountLabel.textColor = UIColor(red: 255 / 255, green: 59 / 255, blue: 48 / 255, alpha: 1)
        default:
            amountLabel.textColor = UIColor(red: 76 / 255, green: 217 / 255, blue: 100 / 255, alpha: 1)
        }
    }
}
