//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/9/21.
//


import XCTest
@testable import ShareThatTo

final class LifecycleTests: XCTestCase {
    
    final class MockedApplicationNetwork: NetworkApplicationProtocol
    {
        public var callCounter = 0;
        func application(completion: @escaping (Result<ApplicationResponse, Swift.Error>) -> Void)
        {
            callCounter += 1;
            completion(.success(ApplicationResponse(cta_link: "http://example.com/\(callCounter)")))
        }
    }
    
    func testLifecycle()
    {
        let notificationCenter = NotificationCenter()
        let network = MockedApplicationNetwork()
        let datastore = ApplicationDatastore()
        let lifecycle = Lifecycle(
            notificationCenter: notificationCenter,
            datastore: datastore,
            network: network
        )
        
        // The application is nil when we started
        XCTAssertNil(datastore.application)

        lifecycle.start()
        XCTAssertEqual(network.callCounter, 1)
        XCTAssertNotNil(datastore.application)
        
        notificationCenter.post(Notification(name: UIApplication.willEnterForegroundNotification))
        XCTAssertEqual(network.callCounter, 2)
        
        // Semi-hacky to ensure we've actually updated the application
        XCTAssertEqual(datastore.application?.cta_link, "http://example.com/2")
        
        // Stop works
        lifecycle.stop()
        notificationCenter.post(Notification(name: UIApplication.willEnterForegroundNotification))
        XCTAssertEqual(network.callCounter, 2) // This won't have changed
    }
    

    static var allTests = [
        ("testLifecycle", testLifecycle),
    ]
}
