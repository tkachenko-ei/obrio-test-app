//
//  AddTransactionViewModel.swift
//  TransactionsTestTask
//
//

import Foundation
import Combine

final class AddTransactionViewModel {
    
    @Published var amount: Double = 0
    @Published var category: Transaction.Category = .other
    @Published private(set) var addTranssactionButtonIsEnabled = false
    @Published private(set) var error: Error?
    
    private let coordinator: AddTransactionCoordinator
    private let databaseService: DatabaseService
    private let analyticsService: AnalyticsService
    private var cancellables = Set<AnyCancellable>()
    
    private let categories = Transaction.Category.allCases
    
    init(
        coordinator: AddTransactionCoordinator,
        databaseService: DatabaseService,
        analyticsService: AnalyticsService
    ) {
        self.coordinator = coordinator
        self.databaseService = databaseService
        self.analyticsService = analyticsService
        
        setupSubscriptions()
    }
    
    func numberOfCategories() -> Int {
        return categories.count
    }
    
    func titleForCategory(at index: Int) -> String? {
        guard categories.indices.contains(index) else {
            return nil
        }
        return categories[index].rawValue.capitalized
    }
    
    func selectedCategory(at index: Int) {
        guard categories.indices.contains(index) else {
            return
        }
        category = categories[index]
    }
    
    func addTranssactionButtonTapped() {
        analyticsService.trackEvent(
            name: "add_transaction_button_tapped",
            parameters: [:]
        )
        
        addTransaction()
    }
    
    private func setupSubscriptions() {
        $amount
            .map { $0 > 0 }
            .assign(to: &$addTranssactionButtonIsEnabled)
    }
    
    func addTransaction() {
        let transaction = Transaction(
            amount: -amount,
            category: category,
            date: .now
        )
        
        databaseService.saveTransaction(transaction)
            .sink { [weak self] completion in
                guard case let .failure(error) = completion else {
                    return
                }
                self?.error = error
                self?.analyticsService.trackEvent(
                    name: "add_transaction_failure",
                    parameters: ["error": error.localizedDescription]
                )
            } receiveValue: { [weak self] in
                self?.coordinator.coordinationResult.send(transaction)
                self?.analyticsService.trackEvent(
                    name: "add_transaction_success",
                    parameters: [:]
                )
            }
            .store(in: &cancellables)
    }
}

