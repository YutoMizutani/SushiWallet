//
//  BCHTestnetAPI.swift
//  SushiWallet
//
//  Created by ym on 2019/04/08.
//  Copyright © 2019 Yuto Mizutani. All rights reserved.
//

import Alamofire
import RxSwift

class BitpayUnspentOutputsAPI: BitpayAPICore, API {
    typealias ResponseType = [UnspentOutputResponse]

    var addresses: [BitcoinAddress]!
    var path: String {
        return "\(endpoint)/addrs/\(addresses!.map { $0.value }.joined(separator: ","))/utxo"
    }
    let method: HTTPMethod = .get

    func request(_ addresses: [BitcoinAddress]) -> Single<[ResponseType.Element.EntityType]> {
        self.addresses = addresses
        return _request().map { $0.map { $0.toEntity() } }
    }

    func request(_ addresses: BitcoinAddress...) -> Single<[ResponseType.Element.EntityType]> {
        return request(addresses)
    }
}
