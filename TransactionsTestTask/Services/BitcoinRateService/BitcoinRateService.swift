//
//  BitcoinRateService.swift
//  TransactionsTestTask
//
//

import Foundation
import Combine

protocol BitcoinRateService: AnyObject {
    var rateUpdated: AnyPublisher<Double, Error> { get }
    
    var cancellables: Set<AnyCancellable> { get set }
    
    func updateRate() -> AnyCancellable
    func updateRate(every interval: TimeInterval) -> AnyCancellable
}

final class BitcoinRateServiceImpl {
    private let rateUpdatedSubject = PassthroughSubject<Double, Error>()
    
    lazy var cancellables = Set<AnyCancellable>()
    
    init() {}
    
    private func fetchBitcoinRate() -> AnyPublisher<Double, Error> {
        let url = URL(string: "https://api.coindesk.com/v1/bpi/currentprice.json")!
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: BitcoinRateResponce.self, decoder: JSONDecoder())
            .map(\.rate)
            .handleEvents(receiveOutput: { rate in
                UserDefaults.standard.setValue(rate, forKey: "BitcoinRate")
            })
            .tryCatch { [] error -> AnyPublisher<Double, Never> in
                guard let rate = UserDefaults.standard.value(forKey: "BitcoinRate") as? Double else {
                    throw error
                }
                return Just(rate).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

extension BitcoinRateServiceImpl: BitcoinRateService {
    var rateUpdated: AnyPublisher<Double, Error> {
        return rateUpdatedSubject.eraseToAnyPublisher()
    }
    
    func updateRate() -> AnyCancellable {
        return fetchBitcoinRate()
            .subscribe(rateUpdatedSubject)
    }
    
    func updateRate(every interval: TimeInterval) -> AnyCancellable {
        return Timer.publish(every: interval, on: .current, in: .common)
            .autoconnect()
            .merge(with: Just(.now))
            .flatMap(maxPublishers: .max(1)) { _ in
                return self.fetchBitcoinRate()
            }
            .subscribe(rateUpdatedSubject)
    }
}
