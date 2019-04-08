//
//  TransactionHistoryTableView.swift
//  SushiWallet
//
//  Created by ym on 2019/04/04.
//  Copyright © 2019 Yuto Mizutani. All rights reserved.
//

import BitcoinKit
import RxDataSources
import UIKit

class TransactionHistoryTableView: UITableView {
    private static var fixedRowHeight: CGFloat = 44

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        configureView()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        configureView()
    }

    private func configureView() {
        separatorColor = .clear
        allowsSelection = false
        rowHeight = TransactionHistoryTableView.fixedRowHeight
        register(TransactionHistoryTableViewCell.self)
    }

    lazy var configureDataSource = RxTableViewSectionedReloadDataSource<SectionOfTransactions>(configureCell: configureCell)

    lazy var configureCell: RxTableViewSectionedReloadDataSource<SectionOfTransactions>.ConfigureCell = { [weak self] _, tableView, indexPath, item in
        guard let self = self else { return UITableViewCell() }
        let cell: TransactionHistoryTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.inject(item.0, address: item.1)
        return cell
    }
}
