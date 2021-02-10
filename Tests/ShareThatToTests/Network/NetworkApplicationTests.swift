//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/9/21.
//

import Foundation

import DVR
import XCTest
@testable import ShareThatTo

final class NetworkApplicationTests: XCTestCase {
    
    static func getAuthenticationDatastore(apiKey: String? = "share_pk_0ad3dc721ee63192fb05ab80bc9e4f72") -> AuthenticationDatastoreProtocol
    {
        let authenticationDatastore = AuthenticationDatastore()
        authenticationDatastore.apiKey = apiKey
        return authenticationDatastore
    }
    static func getNetwork(cassetteName: String, authenticationDatastore: AuthenticationDatastoreProtocol = getAuthenticationDatastore(), baseURL: URL =  URL(string: "http://localhost:3000/api")! ) -> NetworkApplicationProtocol
    {
       
        
        let session = Session(cassetteName: cassetteName, testBundle: TestHelpers.fixtureBundle)
        let network: NetworkApplicationProtocol = Network(
            urlSession: session,
            authenticationDatastore: authenticationDatastore,
            baseURL: baseURL
        )
        return network
    }
    
    func testNetworkApplicationUnavailable()
    {
        // Recording: Terminate server before testing
        let expectation = self.expectation(description: "Network Request")
        let network = NetworkApplicationTests.getNetwork(cassetteName: "application-unavailable")
        network.application {
            (result) in
            switch (result) {
                case .failure(let error):
                    XCTAssert(error as! Network.Error == Network.Error.decoding)
                case .success(let response):
                    XCTAssert(false)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testNetworkApplicationFailure()
    {
        let auth = NetworkApplicationTests.getAuthenticationDatastore(apiKey: "abc")
        let network = NetworkApplicationTests.getNetwork(cassetteName: "application-failure", authenticationDatastore: auth)
        let expectation = self.expectation(description: "Network Request")
        
        network.application {
            (result) in
            switch (result) {
                case .failure(let error):
                    XCTAssert(error as! Network.Error == Network.Error.notAuthenticated)
                case .success(let response):
                    XCTAssert(false)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
        
    }
    
    func testNetworkApplication()
    {
        let network = NetworkApplicationTests.getNetwork(cassetteName: "application-test")
        let expectation = self.expectation(description: "Network Request")
        
        network.application {
            (result) in
            switch (result) {
                case .failure(let error):
                    print(error)
                    XCTAssert(false)
                case .success(let response):
                    XCTAssertNotNil(response.cta_link)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }
    
    static var allTests = [
        ("testNetworkApplication", testNetworkApplication),
    ]
}
