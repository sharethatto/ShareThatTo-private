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
    public init(notificationCenter: NotificationCenter = .default, datastore: ApplicationDatastoreProtocol = ApplicationDatastore.shared, network: NetworkApplicationProtocol = Network.shared)
    {
        self.notificationCenter = notificationCenter
        self.datastore = datastore
        self.network = network
    }
    
    // MARK: Lifecycle
    
    public func start()
    {
        stop() // Ensure we don't do this twice
        notificationCenter.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        refreshSessionData()
    }
    
    public func stop()
    {
        notificationCenter.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    // MARK: - Private
    
    @objc private func willEnterForeground()
    {
        refreshSessionData()
    }
    
    /**
        In the future this will handle more network updating
     */
    private func refreshSessionData()
    {
        network.application { [self] result in
            switch(result) {
            case .failure(_): break
            case .success(let response):
                self.datastore.application = response
            }
        }
    }
    
}
