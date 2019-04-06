//
//  UITableView+Reusable.swift
//  SushiWallet
//
//  Created by ym on 2019/04/06.
//  Copyright © 2019 Yuto Mizutani. All rights reserved.
//

import UIKit

protocol ReusableView: class {
    static var reuseIdentifier: String { get }
}

extension ReusableView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell: ReusableView {}

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }

        return cell
    }
}

extension UITableView {
    func register(_ cells: (UITableViewCell & ReusableView & NibLoadable).Type...) {
        for cell in cells {
            register(cell.nib, forCellReuseIdentifier: cell.reuseIdentifier)
        }
    }
}
