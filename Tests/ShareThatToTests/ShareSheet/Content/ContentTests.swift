//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/6/21.
//

import Foundation

import XCTest
@testable import ShareThatTo

final class ContentTests: XCTestCase {
        
    func testContentProtocolsObeyCastingRules() {
//        let expectation = self.expectation(description: "Scaling")
//        
//        let bundle = Bundle(for: AVURLAssetTest.self)
//        let resourcePath = bundle.resourcePath! + "/ShareThatTo_ShareThatToTests.bundle/Fixtures/vertical-backup.mp4"
//        
//        let resourceURL = URL(fileURLWithPath: resourcePath)
//        
//        do {
//            let videoContent = try VideoContent(videoURL: resourceURL, title: "test title")
//            
//            videoContent.renderThumbnailAndVideo { (result) in
//                switch result
//                {
//                case .failure( _): break
//                case .success(let data):
//                    XCTAssert(data.1.count < 700000)
//                    var attachment = XCTAttachment(data: data.1, uniformTypeIdentifier: "public.data")
//                    attachment.lifetime = .keepAlways
//                    self.add(attachment)
//                    attachment = XCTAttachment(data: data.0, uniformTypeIdentifier: "public.image")
//                    attachment.lifetime = .keepAlways
//                    self.add(attachment)
//                    expectation.fulfill()
//                }
//            }
//        
//        } catch let _
//        {
//            XCTAssert(false)
//        }
//        waitForExpectations(timeout: 5, handler: nil)
        
    }

    static var allTests = [
        ("testContentProtocolsObeyCastingRules", testContentProtocolsObeyCastingRules),
    ]
}

