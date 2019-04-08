//
//  BitpayAPICore.swift
//  SushiWallet
//
//  Created by ym on 2019/04/08.
//  Copyright © 2019 Yuto Mizutani. All rights reserved.
//

import Alamofire
import RxSwift

enum BitpayAPINetwork {
    case bchTestnet
}

class BitpayAPICore {
    var network: BitpayAPINetwork

    init(_ network: BitpayAPINetwork) {
        self.network = network
    }

    var endpoint: String {
        switch network {
        case .bchTestnet:
            return "https://test-bch-insight.bitpay.com/api"
        }
    }
}
