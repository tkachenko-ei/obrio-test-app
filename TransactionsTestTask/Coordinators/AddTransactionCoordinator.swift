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
    
    private lazy var databaseService = ServicesAssembler.databaseService()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start(animated: Bool) -> AnyPublisher<Transaction, Never> {
        let viewModel = AddTransactionViewModel(
            coordinator: self,
            databaseService: databaseService
        )
        let viewController = AddTransactionViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: animated)
        return coordinationResult.eraseToAnyPublisher()
    }
}

