//
//  BitcoinRateServiceTests.swift
//  TransactionsTestTaskTests
//
//

import XCTest
import Combine
@testable import TransactionsTestTask

final class BitcoinRateServiceTests: XCTestCase {
    
    private var bitcoinRateService = ServicesAssembler.bitcoinRateService()
    private var cancellables = Set<AnyCancellable>()

    func testUpdateRate() throws {
        var rate: Double?
        let expectation = expectation(description: #function)
        
        bitcoinRateService.rateUpdated
            .sink(receiveCompletion: { completion in
                expectation.fulfill()
            }, receiveValue: { value in
                rate = value
            })
            .store(in: &cancellables)
        
        bitcoinRateService.updateRate()
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 1)
        
        XCTAssert(rate != nil)
    }
}

