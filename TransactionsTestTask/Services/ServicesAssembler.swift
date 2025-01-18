//
//  ServicesAssembler.swift
//  TransactionsTestTask
//
//

enum ServicesAssembler {
    
    // MARK: - BitcoinRateService
    
    static let bitcoinRateService: PerformOnce<BitcoinRateService> = {
        lazy var analyticsService = Self.analyticsService()
        
        let service = BitcoinRateServiceImpl()
        
        service.rateUpdated
            .sink(receiveCompletion: { completion in
                guard case let .failure(error) = completion else {
                    return
                }

                analyticsService.trackEvent(
                    name: "bitcoin_rate_update_error",
                    parameters: ["error": error.localizedDescription]
                )
            }, receiveValue: { rate in
                analyticsService.trackEvent(
                    name: "bitcoin_rate_update",
                    parameters: ["rate": String(format: "%.2f", rate)]
                )
            })
            .store(in: &service.cancellables)
        
        return { service }
    }()
    
    // MARK: - AnalyticsService
    
    static let analyticsService: PerformOnce<AnalyticsService> = {
        let service = AnalyticsServiceImpl()
        
        return { service }
    }()
    
    // MARK: - DatabaseService
    
    static let databaseService: PerformOnce<DatabaseService> = {
        let service = DatabaseServiceImpl()
        
        return { service }
    }()
}
