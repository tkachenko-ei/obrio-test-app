//
//  DatabaseService.swift
//  TransactionsTestTask
//
//

import CoreData
import Combine

protocol DatabaseService: AnyObject {
    func fetchBalance() -> AnyPublisher<Double, Error>
    func fetchTransactions(offset: Int, limit: Int) -> AnyPublisher<[Transaction], Error>
    func saveTransaction(_ transaction: Transaction) -> AnyPublisher<Void, Error>
}

final class DatabaseServiceImpl {
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TransactionsTestTask")
        container.loadPersistentStores { (persistent, error) in
            if let error {
                fatalError("Unable to initialize Core Data \(error)")
            }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        container.viewContext.shouldDeleteInaccessibleFaults = true
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    init() {}
}

extension DatabaseServiceImpl: DatabaseService {
    func fetchBalance() -> AnyPublisher<Double, Error> {
        let keypathExp = NSExpression(forKeyPath: "amount")
        let expression = NSExpression(forFunction: "sum:", arguments: [keypathExp])
        let amountDescription = NSExpressionDescription()
        amountDescription.expression = expression
        amountDescription.name = "amount"
        amountDescription.expressionResultType = .doubleAttributeType
                
        let context = persistentContainer.viewContext
        let entityName = String(describing: DatabaseTransaction.self)
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.returnsObjectsAsFaults = false
        request.propertiesToFetch = [amountDescription]
        request.resultType = .dictionaryResultType
        
        return Publishers.CoreDataFetchResultsPublisher(
            request: request,
            context: context
        )
        .map { ($0.first as? Dictionary<String, Double>)?["amount"] ?? 0 }
        .eraseToAnyPublisher()
    }
    
    func saveTransaction(_ transaction: Transaction) -> AnyPublisher<Void, Error> {
        let context = persistentContainer.viewContext
        let action = {
            let databaseTransaction = DatabaseTransaction(context: context)
            databaseTransaction.replaceWith(transaction: transaction)
        }
        
        return Publishers.CoreDataSavePublisher(
            action: action,
            context: context
        )
        .eraseToAnyPublisher()
    }
    
    func fetchTransactions(offset: Int, limit: Int) -> AnyPublisher<[Transaction], Error> {
        let context = persistentContainer.viewContext
        let entityName = String(describing: DatabaseTransaction.self)
        let sortDescriptor = NSSortDescriptor(
            key: #keyPath(DatabaseTransaction.date),
            ascending: false
        )
        let request = NSFetchRequest<DatabaseTransaction>(entityName: entityName)
        request.sortDescriptors = [sortDescriptor]
        request.fetchLimit = limit
        request.fetchOffset = offset
        
        return Publishers.CoreDataFetchResultsPublisher(
            request: request,
            context: context
        )
        .map { $0.map(\.transaction) }
        .eraseToAnyPublisher()
    }
}

