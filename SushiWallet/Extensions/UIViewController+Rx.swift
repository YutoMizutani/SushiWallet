//
//  UIViewController+Rx.swift
//  SushiWallet
//
//  Created by ym on 2019/04/06.
//  Copyright © 2019 Yuto Mizutani. All rights reserved.
//

import RxSwift
import UIKit

extension Reactive where Base: UIViewController {
    var viewWillAppear: Observable<[Any]> {
        return sentMessage(#selector(base.viewWillAppear)).share(replay: 1)
    }
}
