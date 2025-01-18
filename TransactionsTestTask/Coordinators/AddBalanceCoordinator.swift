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
    private lazy var analyticsService = ServicesAssembler.analyticsService()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start(animated: Bool) -> AnyPublisher<Transaction, Never> {
        let viewModel = AddBalanceViewModel(
            coordinator: self,
            databaseService: databaseService, 
            analyticsService: analyticsService
        )
        let viewController = AddBalanceViewController(viewModel: viewModel)
        navigationController.present(viewController, animated: true)
        analyticsService.trackEvent(name: "open_add_balance_sheet", parameters: [:])
        return coordinationResult.eraseToAnyPublisher()
    }
}
