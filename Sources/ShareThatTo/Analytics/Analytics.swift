//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/14/21.
//

import Foundation

internal struct AnalyticsEvent: Codable
{
    var event_name: String
    var error_string: String?
}

internal struct ObservabilityEvent: Codable
{
    var event_name: String?
    var message: String?
}

internal struct Contrib: Codable
{
    var contrib_user_id: String?
}

internal struct Application: Codable
{
    var application_slug: String?
}

internal struct WrappedAnalyticsEvent: Codable
{
    var timestamp: String
    var event: AnalyticsEvent?
    var observability: ObservabilityEvent?
    var device: Device
    var context: Context?
    var contrib: Contrib
    var application: Application
}


class Analytics
{
    public static let shared = Analytics()
    
    private var datastore: AnalyticsDatastoreProtocol
    private var contribDatastore: ContribDatastoreProtocol
    private var applicationDatastore: ApplicationDatastoreProtocol
    private var network: NetworkAnalyticsProtocol
    private var interval: TimeInterval
    private var timer: Timer?
    
    public init(
        datastore: AnalyticsDatastoreProtocol = AnalyticsDatastore.shared,
        contribDatastore: ContribDatastoreProtocol = ContribDatastore.shared,
        applicationDatastore: ApplicationDatastoreProtocol = ApplicationDatastore.shared,
        network: NetworkAnalyticsProtocol = Network.shared,
        interval: TimeInterval = 60 * 2
    )
    {
        self.datastore = datastore
        self.contribDatastore = contribDatastore
        self.applicationDatastore = applicationDatastore
        self.network = network
        self.interval = interval
    }
    
    //MARK: Internal interface
    
    internal func addObservabilityEvent(event: ObservabilityEvent)
    {
        addObservabilityEvent(event: event, context: nil)
    }
    
    internal func addObservabilityEvent(event: ObservabilityEvent, context: Context?)
    {
        let contribUserId = self.contribDatastore.userId
        let applicationSlug = self.applicationDatastore.application?.slug
        let wrappedEvent = WrappedAnalyticsEvent(
            timestamp: timestampNow(),
            event: nil,
            observability: event,
            device: DeviceHelper.device(),
            context: context,
            contrib: Contrib(contrib_user_id: contribUserId),
            application: Application(application_slug: applicationSlug)
        )
        self.datastore.addEvent(event: wrappedEvent)
        Logger.shareThatToDebug(string: "[Analytics] logged observability event \(event.event_name): \(wrappedEvent)")
    }
    
    internal func addEvent(event: AnalyticsEvent)
    {
        addEvent(event: event, context: nil)
    }
    
    internal func addEvent(event: AnalyticsEvent, context: Context?)
    {
        let contribUserId = self.contribDatastore.userId
        let applicationSlug = self.applicationDatastore.application?.slug
        let wrappedEvent = WrappedAnalyticsEvent(
            timestamp: timestampNow(),
            event: event,
            observability: nil,
            device: DeviceHelper.device(),
            context: context,
            contrib: Contrib(contrib_user_id: contribUserId),
            application: Application(application_slug: applicationSlug)
        )
        self.datastore.addEvent(event: wrappedEvent)
        Logger.shareThatToDebug(string: "[Analytics] logged analytics event \(event.event_name): \(wrappedEvent)")
    }
    
    internal func start()
    {
        Logger.shareThatToDebug(string: "[Analytics] start")
        stop()
        self.timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            self.upload()
        }
    }
    
    internal func stop()
    {
        Logger.shareThatToDebug(string: "[Analytics] stop")
        guard let timer = timer else {
            return
        }
        timer.invalidate()
        upload()
        self.timer = nil
    }
    
    //MARK: Lifeycle
    
    
    private func upload()
    {
        Logger.shareThatToDebug(string: "[Analytics] upload")
        let events = self.datastore.allEvents()
        Logger.shareThatToDebug(string: "[Analytics] upload events (\(events.count))")
        self.datastore.destroyAll() // Remove everything and re-add it if we fail
        if (events.count == 0) {
            return
        }
        self.network.batchUploadEvents(events: events) { (result) in
            switch (result) {
            case .failure:
                events.forEach { (event) in
                    self.datastore.addEvent(event: event)
                }
            case .success: break
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
