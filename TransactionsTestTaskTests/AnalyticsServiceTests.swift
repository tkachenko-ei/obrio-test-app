//
//  AnalyticsServiceTests.swift
//  TransactionsTestTaskTests
//
//

import XCTest
import Combine
@testable import TransactionsTestTask

final class AnalyticsServiceTests: XCTestCase {
    
    private var analyticsService = ServicesAssembler.analyticsService()
    private var cancellables = Set<AnyCancellable>()

    func testTrackEvent() {
        analyticsService.trackEvent(name: "test_event_1", parameters: [:])
        analyticsService.trackEvent(name: "test_event_2", parameters: ["test_key": "test_value"])
        
        let events = analyticsService.fetchEvents(name: nil, between: nil)
        
        XCTAssert(events.contains(where: { $0.name == "test_event_1" }))
        XCTAssert(events.contains(where: { $0.parameters.keys.contains("test_key") }))
        XCTAssert(events.contains(where: { $0.parameters.values.contains("test_value") }))
    }
    
    func testFetchEvents() {
        analyticsService.trackEvent(name: "test_event_1", parameters: [:])
        sleep(1)
        let lowerDate = Date.now
        sleep(1)
        analyticsService.trackEvent(name: "test_event_2", parameters: [:])
        sleep(1)
        let upperDate = Date.now
        sleep(1)
        analyticsService.trackEvent(name: "test_event_3", parameters: [:])
        
        var events = analyticsService.fetchEvents(name: nil, between: lowerDate...upperDate)
        
        XCTAssertFalse(events.contains(where: { $0.name == "test_event_1" }))
        XCTAssertTrue(events.contains(where: { $0.name == "test_event_2" }))
        XCTAssertFalse(events.contains(where: { $0.name == "test_event_3" }))
        
        events = analyticsService.fetchEvents(name: "test_event_3", between: nil)
        
        XCTAssertFalse(events.contains(where: { $0.name == "test_event_1" }))
        XCTAssertFalse(events.contains(where: { $0.name == "test_event_2" }))
        XCTAssertTrue(events.contains(where: { $0.name == "test_event_3" }))
    }
}

