//
//  TransactionsViewAction.swift
//  TransactionsTestTask
//
//

import Foundation

typealias TransactionSection = (section: Date, transaction: Transaction)
typealias TransactionsSection = (section: Date, transactions: [Transaction])

enum TransactionsViewAction {
    case showNewTransaction(TransactionSection)
    case showNewPageTransactions([TransactionsSection])
}
