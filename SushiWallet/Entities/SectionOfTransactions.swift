//
//  SectionOfTransactions.swift
//  SushiWallet
//
//  Created by ym on 2019/04/07.
//  Copyright © 2019 Yuto Mizutani. All rights reserved.
//

import BitcoinKit
import RxDataSources

struct SectionOfTransactions {
    var items: [(Transaction, BitcoinAddress)]
}

extension SectionOfTransactions: SectionModelType {
    typealias Item = (Transaction, BitcoinAddress)

    init(original: SectionOfTransactions, items: [SectionOfTransactions.Item]) {
        self = original
        self.items = items
    }
}
