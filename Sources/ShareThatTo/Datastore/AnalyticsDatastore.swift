//
//  File.swift
//
//
//  Created by Brian Anglin on 2/9/21.
//

import Foundation

protocol AnalyticsDatastoreProtocol
{
    func addEvent(event: WrappedAnalyticsEvent)
    func allEvents() -> [WrappedAnalyticsEvent]
    func destroyAll()
}

internal class AnalyticsDatastore: AnalyticsDatastoreProtocol
{
    func addEvent(event: WrappedAnalyticsEvent) {
        events.append(event)
    }
    
    func allEvents() -> [WrappedAnalyticsEvent] {
        return events
    }
    
    func destroyAll() {
        events = []
    }
    
    internal static let shared = AnalyticsDatastore()
    private var events: [WrappedAnalyticsEvent] = [];
    public init() { }
}
