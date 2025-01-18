//
//  CoreDataSavePublisher.swift
//  TransactionsTestTask
//
//

import CoreData
import Combine

extension Publishers {
    struct CoreDataSavePublisher: Publisher {
        typealias Output = Void
        typealias Failure = Error
        
        private let action: () -> Void
        private let context: NSManagedObjectContext
        
        init(action: @escaping () -> Void, context: NSManagedObjectContext) {
            self.action = action
            self.context = context
        }
        
        func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
            let subscription = Subscription(subscriber: subscriber, context: context, action: action)
            subscriber.receive(subscription: subscription)
        }
    }
}

extension Publishers.CoreDataSavePublisher {
    class Subscription<S>: Combine.Subscription
    where S : Subscriber, Failure == S.Failure, Output == S.Input {
        private var subscriber: S?
        private let action: () -> Void
        private let context: NSManagedObjectContext
        
        init(subscriber: S, context: NSManagedObjectContext, action: @escaping () -> Void) {
            self.subscriber = subscriber
            self.context = context
            self.action = action
        }
        
        func request(_ demand: Subscribers.Demand) {
            var demand = demand
            guard let subscriber = subscriber, demand > 0 else { return }
            
            do {
                action()
                demand -= 1
                try context.save()
                demand += subscriber.receive()
            } catch {
                subscriber.receive(completion: .failure(error as NSError))
            }
        }
        
        func cancel() {
            subscriber = nil
        }
    }
}

