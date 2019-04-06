//
//  NibLoadable.swift
//  SushiWallet
//
//  Created by ym on 2019/04/06.
//  Copyright © 2019 Yuto Mizutani. All rights reserved.
//

import UIKit

/// Nib の読み込みが可能な protocol
protocol NibLoadable {
    /// クラス名と一致した Nib ファイルを読み出す
    static var nib: UINib { get }
}

extension NibLoadable where Self: UIView {
    /// クラス名と一致した Nib ファイルを読み出す
    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: nil)
    }
}
