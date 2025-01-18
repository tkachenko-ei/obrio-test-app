//
//  AddBalanceCoordinator.swift
//  TransactionsTestTask
//
//

import UIKit
import Combine

final class AddBalanceCoordinator: Coordinator<Transaction> {
    unowned let navigationController: UINavigationController
    
    let coordinationResult = PassthroughSubject<Transaction, Never>()
    
    private lazy var databaseService = ServicesAssembler.databaseService()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start(animated: Bool) -> AnyPublisher<Transaction, Never> {
        let viewModel = AddBalanceViewModel(
            coordinator: self,
            databaseService: databaseService
        )
        let viewController = AddBalanceViewController(viewModel: viewModel)
        navigationController.present(viewController, animated: true)
        return coordinationResult.eraseToAnyPublisher()
    }
}
