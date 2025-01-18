//
//  DatabaseTransaction.swift
//  TransactionsTestTask
//
//

import Foundation
import CoreData

@objc(DatabaseTransaction)
class DatabaseTransaction: NSManagedObject {
    @NSManaged public var amount: Double
    @NSManaged public var category: String?
    @NSManaged public var date: Date
}
    
extension DatabaseTransaction {
    
    var transaction: Transaction {
        Transaction(
            amount: amount,
            category: {
                guard let category else { return nil }
                return Transaction.Category(rawValue: category)
            }(),
            date: date
        )
    }

    func replaceWith(transaction: Transaction) {
        amount = transaction.amount
        category = transaction.category?.rawValue
        date = transaction.date
    }
}

