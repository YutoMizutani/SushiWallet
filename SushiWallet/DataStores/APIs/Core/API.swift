//
//  API.swift
//  SushiWallet
//
//  Created by ym on 2019/04/08.
//  Copyright © 2019 Yuto Mizutani. All rights reserved.
//

import Alamofire
import RxSwift

protocol API {
    associatedtype ResponseType: Decodable

    var path: String { get }
    var method: HTTPMethod { get }
}

extension API {
    /// Success handler
    private typealias SuccessHandler<ResponseType> = (_ response: ResponseType) -> Void
    /// Failure handler
    private typealias FailureHandler = (_ error: Error) -> Void

    private func request(_ parameters: Parameters?, success: SuccessHandler<ResponseType>?, failure: FailureHandler?) {
        let url = path

        print("API CONNECTION OCCURRED: URL=\(url), method=\(method.rawValue), parameters=\(parameters?.description ?? "nil")")

        Alamofire.request(url,
                          method: method,
                          parameters: parameters,
                          encoding: URLEncoding.default)
            .responseData {
                switch $0.result {
                case .success:
                    switch self.method {
                    case .get, .post, .put:
                        guard let data = $0.data else { return }

                        print("RECEIVED JSON: \(String(data: data, encoding: .utf8) ?? "")")

                        let decoder: JSONDecoder = JSONDecoder()
                        guard let response: ResponseType = try? decoder.decode(ResponseType.self, from: data) else { return }
                        success?(response)
                    case .delete:
                        guard $0.error == nil else {
                            failure?($0.error!)
                            return
                        }
                        // Delete method returns empty
                        let response = EmptyResponse() as! ResponseType
                        success?(response)
                    default:
                        fatalError("Could not implemented yet")
                    }
                case .failure(let error):
                    failure?(error)
                }
            }
    }

    func _request(_ parameters: Parameters? = nil) -> Single<ResponseType> {
        return Single.create { single -> Disposable in
                let success: SuccessHandler<ResponseType> = { single(.success($0)) }
                let failure: FailureHandler = { single(.error($0)) }
                self.request(parameters, success: success, failure: failure)
                return Disposables.create()
            }
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
    }
}
