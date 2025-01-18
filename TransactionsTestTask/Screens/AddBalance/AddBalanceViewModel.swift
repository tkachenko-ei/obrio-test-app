//
//  AddBalanceViewModel.swift
//  TransactionsTestTask
//
//

import Foundation
import Combine

final class AddBalanceViewModel {
    
    @Published var amount: Double = 0
    @Published private(set) var addBalanceButtonIsEnabled = false
    @Published private(set) var error: Error?
    
    private let coordinator: AddBalanceCoordinator
    private let databaseService: DatabaseService
    private var cancellables = Set<AnyCancellable>()
    
    init(coordinator: AddBalanceCoordinator, databaseService: DatabaseService) {
        self.coordinator = coordinator
        self.databaseService = databaseService
        
        setupSubscriptions()
    }
    
    func addBalanceButtonTapped() {
        let transaction = Transaction(amount: amount, date: .now)
        
        databaseService.saveTransaction(transaction)
            .sink { [weak self] completion in
                guard case let .failure(error) = completion else {
                    return
                }
                self?.error = error
            } receiveValue: { [weak self] in
                self?.coordinator.coordinationResult.send(transaction)
            }
            .store(in: &cancellables)
    }
    
    private func setupSubscriptions() {
        $amount
            .map { $0 > 0 }
            .assign(to: &$addBalanceButtonIsEnabled)
    }
}
