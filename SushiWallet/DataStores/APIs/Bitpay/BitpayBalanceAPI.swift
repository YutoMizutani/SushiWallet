//
//  BitpayBalanceAPI.swift
//  SushiWallet
//
//  Created by ym on 2019/04/08.
//  Copyright © 2019 Yuto Mizutani. All rights reserved.
//

import Alamofire
import RxSwift

/// bitpay balance API
///
/// https://blockexplorer.com/api-ref #Address Properties
/// - Example: https://test-bch-insight.bitpay.com/api/addr/qrwr77w5crw8wp49q0m42zdrvj5ly4kdqsxckje0xj/balance
class BitpayBalanceAPI: BitpayAPICore, API {
    typealias ResponseType = Decimal

    var address: BitcoinAddress!
    var path: String {
        return "\(endpoint)/addr/\(address!.value)/balance"
    }
    let method: HTTPMethod = .get

    func request(_ address: BitcoinAddress) -> Single<ResponseType> {
        self.address = address
        return Single.create { single -> Disposable in
            print("API CONNECTION OCCURRED: URL=\(self.path), method=\(self.method.rawValue), parameters=nil")

            Alamofire.request(self.path,
                              method: self.method,
                              parameters: nil,
                              encoding: URLEncoding.default)
                .responseData {
                    switch $0.result {
                    case .success:
                        guard
                            let data = $0.data,
                            let json = String(data: data, encoding: .utf8),
                            let result = Decimal(string: json)
                        else { return }

                        print("RECEIVED JSON: \(json)")
                        single(.success(result))
                    case .failure(let error):
                        single(.error(error))
                    }
                }
            return Disposables.create()
        }
        .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
        .observeOn(MainScheduler.asyncInstance)
    }
}
