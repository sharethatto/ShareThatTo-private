//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/14/21.
//

import Foundation

public struct AnalyticsEvent: Codable
{
    var event_name: String
}

internal struct WrappedAnalyticsEvent: Codable
{
    var timestamp: String
    var event: AnalyticsEvent
}


class Analytics
{
    public static let shared = Analytics()
    
    private var datastore: AnalyticsDatastoreProtocol
    private var network: NetworkAnalyticsProtocol
    private var interval: TimeInterval
    private var timer: Timer?
    
    public init(
        datastore: AnalyticsDatastoreProtocol = AnalyticsDatastore.shared,
        network: NetworkAnalyticsProtocol = Network.shared,
        interval: TimeInterval = 60 * 2
    )
    {
        self.datastore = datastore
        self.network = network
        
    }
    
    //MARK: Internal interface
    
    internal func addEvent(event: AnalyticsEvent)
    {
        let wrappedEvent = WrappedAnalyticsEvent(timestamp: timestampNow(), event: event)
        self.datastore.addEvent(event: wrappedEvent)
    }
    
    internal func start()
    {
        stop()
        self.timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            self.upload()
        }
    }
    
    internal func stop()
    {
        guard let timer = timer else {
            return
        }
        timer.invalidate()
        self.timer = nil
    }
    
    //MARK: Lifeycle
    
    
    private func upload()
    {
        let events = self.datastore.allEvents()
        
        self.network.batchUploadEvents(events: events) { (result) in
            switch (result) {
            case .failure: break
            case .success:
                self.datastore.destroyAll()
            }
        }
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
    
    private func timestampNow() -> String
    {
        return dateFormatter.string(from: Date())
    }
}
