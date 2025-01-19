//
//  HomeCoordinator.swift
//  TransactionsTestTask
//
//

import UIKit
import Combine

final class HomeCoordinator: Coordinator<Void> {
    unowned let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start(animated: Bool) -> AnyPublisher<Void, Never> {
        let databaseService = ServicesAssembler.shared.resolve(DatabaseService.self)
        let bitcoinRateService = ServicesAssembler.shared.resolve(BitcoinRateService.self)
        let viewModel = HomeViewModel(
            coordinator: self,
            databaseService: databaseService,
            bitcoinRateService: bitcoinRateService
        )
        let viewController = HomeViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: animated)
        return Empty(completeImmediately: false)
            .eraseToAnyPublisher()
    }
    
    func navigateToAddTransaction() -> AnyPublisher<Transaction, Never> {
        let coordinator = AddTransactionCoordinator(navigationController: navigationController)
        return coordinate(to: coordinator)
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.navigationController.popViewController(animated: true)
            })
            .eraseToAnyPublisher()
    }
    
    func navigateToAddBalance() -> AnyPublisher<Transaction, Never> {
        let coordinator = AddBalanceCoordinator(navigationController: navigationController)
        return coordinate(to: coordinator)
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.navigationController.dismiss(animated: true)
            })
            .eraseToAnyPublisher()
    }
}
