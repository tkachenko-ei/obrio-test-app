//
//  BalanceViewModel.swift
//  TransactionsTestTask
//
//

import Foundation
import Combine

final class BalanceViewModel {
    
    @Published private(set) var bitcoinRate: Double = 0
    @Published private(set) var bitcoinBalance: Double = 0
    
    var bitcoinBalanceReplenishTappedPublisher: AnyPublisher<Void, Never> {
        bitcoinBalanceReplenishTapped.eraseToAnyPublisher()
    }
    
    var addTransactionTappedPublisher: AnyPublisher<Void, Never> {
        addTransactionTapped.eraseToAnyPublisher()
    }
    
    private let bitcoinBalanceReplenishTapped = PassthroughSubject<Void, Never>()
    private let addTransactionTapped = PassthroughSubject<Void, Never>()
    
    private let databaseService: DatabaseService
    private let bitcoinRateService: BitcoinRateService
    private var cancellables = Set<AnyCancellable>()
    
    init(databaseService: DatabaseService, bitcoinRateService: BitcoinRateService) {
        self.databaseService = databaseService
        self.bitcoinRateService = bitcoinRateService
        
        setupSubscriptions()
        updateBitcoinBalance()
    }
    
    private func setupSubscriptions() {
        bitcoinRateService.rateUpdated
            .catch{ _ in Empty<Double, Never>() }
            .assign(to: &$bitcoinRate)
        
        bitcoinRateService.updateRate(every: 2)
            .store(in: &cancellables)
    }
    
    func updateBitcoinBalance() {
        databaseService.fetchBalance()
            .catch{ _ in Empty<Double, Never>() }
            .assign(to: &$bitcoinBalance)
    }
    
    func updateBitcoinBalance(_ balance: Double) {
        bitcoinBalance = balance
    }
    
    func bitcoinBalanceReplenishButtonTapped() {
        bitcoinBalanceReplenishTapped.send()
    }
    
    func addTransactionButtonTapped() {
        addTransactionTapped.send()
    }
}

