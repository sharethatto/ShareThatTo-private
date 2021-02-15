//
//  File.swift
//
//
//  Created by Brian Anglin on 2/9/21.
//

import Foundation

protocol AnalyticsDatastoreProtocol
{
    func addEvent(event: Codable)
    func allEvents() -> [Codable]
    func destroyAll()
}

internal class AnalyticsDatastore: AnalyticsDatastoreProtocol
{
    func addEvent(event: Codable) {
        events.append(event)
    }
    
    func allEvents() -> [Codable] {
        return events
    }
    
    func destroyAll() {
        events = []
    }
    
    internal static let shared = AnalyticsDatastore()
    private var events: [Codable] = [];
    public init() { }
}
