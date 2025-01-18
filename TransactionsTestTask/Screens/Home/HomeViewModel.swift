//
//  HomeViewModel.swift
//  TransactionsTestTask
//
//

import Foundation
import Combine

final class HomeViewModel {
    
    let balance: BalanceViewModel
    
    var transactionsViewActionPublisher: AnyPublisher<TransactionsViewAction, Never> {
        return transactionsViewAction.eraseToAnyPublisher()
    }
    
    private let transactionsViewAction = PassthroughSubject<TransactionsViewAction, Never>()
    private let componentsForGroupingTransactions: Set<Calendar.Component> = [.day, .year, .month]
    private let transactionsLimit = 20
    private var transactionsOffset = 0

    private let coordinator: HomeCoordinator
    private let databaseService: DatabaseService
    private var cancellables = Set<AnyCancellable>()
    
    init(
        coordinator: HomeCoordinator,
        databaseService: DatabaseService,
        bitcoinRateService: BitcoinRateService
    ) {
        self.balance = BalanceViewModel(
            databaseService: databaseService,
            bitcoinRateService: bitcoinRateService
        )
        self.coordinator = coordinator
        self.databaseService = databaseService
        
        setupSubscriptions()
    }
    
    func loadMoreTransactions() {
        transactionsOffset += transactionsLimit
        fetchTransactions()
            .catch { [weak self] _ in
                if let self {
                    self.transactionsOffset -= self.transactionsLimit
                }
                return Empty<[TransactionsSection], Never>()
            }
            .filter { !$0.isEmpty }
            .map { .showNewPageTransactions($0) }
            .subscribe(transactionsViewAction)
            .store(in: &cancellables)
    }
    
    private func setupSubscriptions() {
        fetchTransactions()
            .catch { _ in Empty<[TransactionsSection], Never>() }
            .map { .showNewPageTransactions($0) }
            .subscribe(transactionsViewAction)
            .store(in: &cancellables)
        
        setupAddTransactionSubscription()
        setupBitcoinBalanceReplenishSubscription()
    }
    
    private func setupAddTransactionSubscription() {
        let publisher = balance.addTransactionTappedPublisher
            .flatMap { [unowned self] _ in
                self.coordinator.navigateToAddTransaction()
            }
            .share()
        
        publisher
            .sink { [weak self] _ in
                self?.balance.updateBitcoinBalance()
            }
            .store(in: &cancellables)
        
        publisher
            .compactMap { [weak self] transaction in
                guard
                    let components = self?.componentsForGroupingTransactions,
                    let date = Calendar.current.date(
                        from: Calendar.current.dateComponents(components, from: transaction.date)
                    )
                else { return nil }
                return TransactionSection(section: date, transaction: transaction)
            }
            .map { .showNewTransaction($0) }
            .subscribe(transactionsViewAction)
            .store(in: &cancellables)
    }
    
    private func setupBitcoinBalanceReplenishSubscription() {
        let publisher = balance.bitcoinBalanceReplenishTappedPublisher
            .flatMap { [unowned self] _ in
                self.coordinator.navigateToAddBalance()
            }
            .share()
        
        publisher
            .sink { [weak self] _ in
                self?.balance.updateBitcoinBalance()
            }
            .store(in: &cancellables)
        
        publisher
            .compactMap { [weak self] transaction in
                guard
                    let components = self?.componentsForGroupingTransactions,
                    let date = Calendar.current.date(
                        from: Calendar.current.dateComponents(components, from: transaction.date)
                    )
                else { return nil }
                return TransactionSection(section: date, transaction: transaction)
            }
            .map { .showNewTransaction($0) }
            .subscribe(transactionsViewAction)
            .store(in: &cancellables)
    }
    
    private func fetchTransactions() -> AnyPublisher<[TransactionsSection], Error> {
        databaseService.fetchTransactions(offset: transactionsOffset, limit: transactionsLimit)
            .filter { !$0.isEmpty }
            .compactMap { [weak self] transactions in
                return self?.groupingTransactions(transactions)
            }
            .eraseToAnyPublisher()
    }
    
    private func groupingTransactions(_ transactions: [Transaction]) -> [TransactionsSection] {
        transactions.reduce(into: [TransactionsSection]()) { sections, transaction in
            let currentTransactionComponents = Calendar.current.dateComponents(
                componentsForGroupingTransactions,
                from: transaction.date
            )
            
            guard let currentTransactionDateByComponents = Calendar.current.date(from: currentTransactionComponents) else {
                return
            }
            
            if let lastSection = sections.last {
                let previousTransactionComponents = Calendar.current.dateComponents(
                    componentsForGroupingTransactions,
                    from: lastSection.section
                )
                
                if
                    let previousTransactionDateByComponents = Calendar.current.date(from: previousTransactionComponents),
                    previousTransactionDateByComponents == currentTransactionDateByComponents
                {
                    let newTransactions = lastSection.transactions + [transaction]
                    sections[sections.endIndex - 1] = (section: lastSection.section, transactions: newTransactions)
                } else {
                    sections.append((section: currentTransactionDateByComponents, transactions: [transaction]))
                }
            } else {
                sections.append((section: currentTransactionDateByComponents, transactions: [transaction]))
            }
        }
    }
}

