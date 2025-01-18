//
//  Coordinator.swift
//  TransactionsTestTask
//
//

import UIKit
import Combine

open class Coordinator<CoordinationResult> {
    var cancellables = Set<AnyCancellable>()

    @discardableResult
    open func coordinate<T>(
        to coordinator: Coordinator<T>,
        animated: Bool = true
    ) -> AnyPublisher<T, Never> {
        return coordinator.start(animated: animated)
    }
    
    open func start(animated: Bool) -> AnyPublisher<CoordinationResult, Never> {
        fatalError("start() method must be implemented")
    }
}
