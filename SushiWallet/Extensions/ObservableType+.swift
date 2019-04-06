//
//  RxExtensions.swift
//  SushiWallet
//
//  Created by ym on 2019/04/05.
//  Copyright © 2019 Yuto Mizutani. All rights reserved.
//

import RxSwift

extension ObservableType {
    func mapToVoid() -> Observable<Void> {
        return map { _ in }
    }

    func unwrap<T>() -> Observable<T> where E == T? {
        return filter { $0 != nil }.map { $0! }
    }
}
