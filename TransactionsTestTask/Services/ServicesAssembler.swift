//
//  ServicesAssembler.swift
//  TransactionsTestTask
//
//

import Combine

final class ServicesAssembler {
    
    static let shared = ServicesAssembler()
    
    private var registry = [String: () -> Any]()
    private var singletons = [String: Any]()
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        register(DatabaseService.self) { DatabaseServiceImpl() }
        registerSingleton(AnalyticsService.self) { AnalyticsServiceImpl() }
        registerSingleton(BitcoinRateService.self) { [unowned self] in
            let analyticsService = resolve(AnalyticsService.self)
            
            let bitcoinRateService = BitcoinRateServiceImpl()
            bitcoinRateService.rateUpdated
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
                .store(in: &self.cancellables)
            return bitcoinRateService
        }
    }

    func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        let key = String(describing: type)
        registry[key] = factory
    }
    
    func registerSingleton<T>(_ type: T.Type, factory: @escaping () -> T) {
        let key = String(describing: type)
        var instance: T?
        registry[key] = {
            if instance == nil {
                instance = factory()
            }
            return instance!
        }
    }
    
    func resolve<T>(_ type: T.Type) -> T {
        let key = String(describing: type)
        if let instance = singletons[key] as? T {
            return instance
        } else if let factory = registry[key]?() as? T {
            singletons[key] = factory
            return factory
        } else {
            fatalError("No registered entry for \(T.self)")
        }
    }
}
