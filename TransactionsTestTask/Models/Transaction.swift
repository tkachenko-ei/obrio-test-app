//
//  Transaction.swift
//  TransactionsTestTask
//
//

import Foundation

struct Transaction: Hashable {
    var amount: Double
    var category: Category?
    var date: Date
}

extension Transaction {
    enum Category: String, Hashable, CaseIterable {
        case other, groceries, taxi, electronics, restaurant
    }
}
