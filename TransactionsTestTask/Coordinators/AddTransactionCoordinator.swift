//
//  AddTransactionCoordinator.swift
//  TransactionsTestTask
//
//

import UIKit
import Combine

final class AddTransactionCoordinator: Coordinator<Transaction> {
    unowned let navigationController: UINavigationController
    
    let coordinationResult = PassthroughSubject<Transaction, Never>()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start(animated: Bool) -> AnyPublisher<Transaction, Never> {
        let databaseService = ServicesAssembler.shared.resolve(DatabaseService.self)
        let analyticsService = ServicesAssembler.shared.resolve(AnalyticsService.self)
        let viewModel = AddTransactionViewModel(
            coordinator: self,
            databaseService: databaseService,
            analyticsService: analyticsService
        )
        let viewController = AddTransactionViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: animated)
        analyticsService.trackEvent(name: "open_add_transaction_screen", parameters: [:])
        return coordinationResult.eraseToAnyPublisher()
    }
}

