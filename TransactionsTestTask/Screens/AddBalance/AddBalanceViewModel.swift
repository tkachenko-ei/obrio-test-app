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
    private let analyticsService: AnalyticsService
    private var cancellables = Set<AnyCancellable>()
    
    init(
        coordinator: AddBalanceCoordinator,
        databaseService: DatabaseService,
        analyticsService: AnalyticsService
    ) {
        self.coordinator = coordinator
        self.databaseService = databaseService
        self.analyticsService = analyticsService
        
        setupSubscriptions()
    }
    
    func addBalanceButtonTapped() {
        analyticsService.trackEvent(
            name: "add_balance_button_tapped",
            parameters: [:]
        )
        
        addBalance()
    }
    
    private func setupSubscriptions() {
        $amount
            .map { $0 > 0 }
            .assign(to: &$addBalanceButtonIsEnabled)
    }
    
    private func addBalance() {
        let transaction = Transaction(amount: amount, date: .now)
        
        databaseService.saveTransaction(transaction)
            .sink { [weak self] completion in
                guard case let .failure(error) = completion else {
                    return
                }
                self?.error = error
                self?.analyticsService.trackEvent(
                    name: "add_balance_failure",
                    parameters: ["error": error.localizedDescription]
                )
            } receiveValue: { [weak self] in
                self?.coordinator.coordinationResult.send(transaction)
                self?.analyticsService.trackEvent(
                    name: "add_balance_success",
                    parameters: [:]
                )
            }
            .store(in: &cancellables)
    }
}
