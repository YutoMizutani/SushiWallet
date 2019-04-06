//
//  SectionOfPayment.swift
//  SushiWallet
//
//  Created by ym on 2019/04/07.
//  Copyright © 2019 Yuto Mizutani. All rights reserved.
//

import BitcoinKit
import RxDataSources

struct SectionOfPayment {
    var items: [Payment]
}

extension SectionOfPayment: SectionModelType {
    typealias Item = Payment

    init(original: SectionOfPayment, items: [SectionOfPayment.Item]) {
        self = original
        self.items = items
    }
}
