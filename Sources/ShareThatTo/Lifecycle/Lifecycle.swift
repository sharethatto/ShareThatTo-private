//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/9/21.
//

import UIKit
import Foundation

protocol LifecycleProtocol {
    func start()
    func stop()
}

/**
 Lifecycle
 Lifecycle handles updating state as lifecycle events change
 */
internal class Lifecycle: LifecycleProtocol
{
    private let notificationCenter: NotificationCenter
    private var datastore: ApplicationDatastoreProtocol
    private var network: NetworkApplicationProtocol
    private var analytics: Analytics
    public init(
        notificationCenter: NotificationCenter = .default,
        datastore: ApplicationDatastoreProtocol = ApplicationDatastore.shared,
        network: NetworkApplicationProtocol = Network.shared,
        analytics: Analytics = Analytics.shared
        
    )
    {
        self.notificationCenter = notificationCenter
        self.datastore = datastore
        self.network = network
        self.analytics = analytics
    }
    
    // MARK: Lifecycle
    
    public func start()
    {
        
        stop() // Ensure we don't do this twice
        shareThatToDebug(string: "[Lifecycle start]")
        notificationCenter.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        refreshSessionData()
        analytics.start()
    }
    
    public func stop()
    {
        shareThatToDebug(string: "[Lifecycle stop]")
        analytics.stop()
        notificationCenter.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    // MARK: - Private
    
    @objc private func willEnterForeground()
    {
        Analytics.shared.addEvent(event: AnalyticsEvent(event_name: "lifecycle.app_opened", error_string: nil))
        refreshSessionData()
        UGCLifecycleManager.appDidMoveToForeground()
    }
    
    @objc private func didEnterBackground()
    {
        UGCLifecycleManager.appDidMoveToBackground()
    }
    
    
    private var lastUpdated: Date?
    /**
        In the future this will handle more network updating
     */
    private func refreshSessionData()
    {
        
        if let date = lastUpdated {
            // If we've updated in the last minute, return
            if (date.addingTimeInterval(60) > Date())
            {
                return
            }
        }
        lastUpdated = Date()
        shareThatToDebug(string: "[Lifecycle refreshApplication]")
        network.application { [self] result in
            switch(result) {
            case .failure(_): break
            case .success(let response):
                self.datastore.application = response
            }
        }
    }
    
}
