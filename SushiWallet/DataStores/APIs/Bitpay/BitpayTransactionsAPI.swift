//
//  BitpayTransactionsAPI.swift
//  SushiWallet
//
//  Created by ym on 2019/04/08.
//  Copyright © 2019 Yuto Mizutani. All rights reserved.
//

import Alamofire
import RxSwift

/// https://test-bch-insight.bitpay.com/api/txs/?address=n1bWze4MkAdf3rUkXLZkA7xpmzGiUn4cJK
class BitpayTransactionsAPI: BitpayAPICore, API {
    typealias ResponseType = TransactionsResponse

    var path: String {
        return "\(endpoint)/txs/"
    }
    let method: HTTPMethod = .get

    func request(_ address: BitcoinAddress) -> Single<ResponseType.EntityType> {
        var parameters: Parameters = [:]
        parameters["address"] = address.removedPrefix
        return _request(parameters).map { $0.toEntity() }
    }
}
