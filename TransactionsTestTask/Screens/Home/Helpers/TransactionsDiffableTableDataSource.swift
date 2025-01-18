//
//  TransactionsDiffableTableDataSource.swift
//  TransactionsTestTask
//
//

import UIKit

final class TransactionsDiffableTableDataSource: UITableViewDiffableDataSource<Date, Transaction> {
    
    init(tableView: UITableView) {
        super.init(tableView: tableView) { tableView, indexPath, transaction in
            let cell = tableView.dequeueReusableCell(TransactionCell.self, indexPath)
            cell.transaction = transaction
            cell.selectionStyle = .none
            return cell
        }
        
        tableView.register(TransactionCell.self)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let snapshot = snapshot()
        
        guard snapshot.sectionIdentifiers.indices.contains(section) else {
            return nil
        }
        
        return snapshot.sectionIdentifiers[section].formatted(date: .abbreviated, time: .omitted)
    }
}

