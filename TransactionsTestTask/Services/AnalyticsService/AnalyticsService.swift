//
//  AnalyticsService.swift
//  TransactionsTestTask
//
//

import Foundation

protocol AnalyticsService: AnyObject {
    
    func trackEvent(name: String, parameters: [String: String])
    func fetchEvents(name: String?, between range: ClosedRange<Date>?) -> [AnalyticsEvent]
}

final class AnalyticsServiceImpl {
    
    private var events: [AnalyticsEvent] = []
    
    init() {}
    
    private func filterEvents(_ events: [AnalyticsEvent], byName name: String) -> [AnalyticsEvent] {
        return events.filter { $0.name == name }
    }
    
    private func filterEvents(_ events: [AnalyticsEvent], byDates range: ClosedRange<Date>) -> [AnalyticsEvent] {
        return events.filter { range.lowerBound < $0.date && $0.date < range.upperBound }
    }
}

extension AnalyticsServiceImpl: AnalyticsService {
    
    func trackEvent(name: String, parameters: [String: String]) {
        let event = AnalyticsEvent(
            name: name,
            parameters: parameters,
            date: .now
        )
        
        events.append(event)
    }
    
    func fetchEvents(name: String? = nil, between range: ClosedRange<Date>? = nil) -> [AnalyticsEvent] {
        var filteredEvents = events
        if let name {
            filteredEvents = filterEvents(events, byName: name)
        }
        if let range {
            filteredEvents = filterEvents(events, byDates: range)
        }
        return filteredEvents
    }
}
