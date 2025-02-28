//
//  CoreDataFetchResultsPublisher.swift
//  TransactionsTestTask
//
//

import CoreData
import Combine

extension Publishers {
    struct CoreDataFetchResultsPublisher<Entity>: Publisher where Entity: NSFetchRequestResult {
        typealias Output = [Entity]
        typealias Failure = Error
        
        private let request: NSFetchRequest<Entity>
        private let context: NSManagedObjectContext
        
        init(request: NSFetchRequest<Entity>, context: NSManagedObjectContext) {
            self.request = request
            self.context = context
        }
        
        func receive<S>(subscriber: S)
        where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
            let subscription = Subscription(
                subscriber: subscriber,
                context: context,
                request: request
            )
            subscriber.receive(subscription: subscription)
        }
    }
}

extension Publishers.CoreDataFetchResultsPublisher {
    final class Subscription<S>: Combine.Subscription
    where S: Subscriber, Failure == S.Failure, Output == S.Input {
        private var subscriber: S?
        private var request: NSFetchRequest<Entity>
        private var context: NSManagedObjectContext
        
        init(subscriber: S, context: NSManagedObjectContext, request: NSFetchRequest<Entity>) {
            self.subscriber = subscriber
            self.context = context
            self.request = request
        }
        
        func request(_ demand: Subscribers.Demand) {
            var demand = demand
            guard let subscriber = subscriber, demand > 0 else { return }
            do {
                demand -= 1
                let items = try context.fetch(request)
                demand += subscriber.receive(items)
            } catch {
                subscriber.receive(completion: .failure(error as NSError))
            }
        }
        
        func cancel() {
            self.subscriber = nil
        }
    }
}
