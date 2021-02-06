//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/3/21.
//

import AVKit
import XCTest
@testable import ShareThatTo

final class AVURLAssetTest: XCTestCase {
    func testGeneratesThumbnail() {
        let bundle = Bundle(for: AVURLAssetTest.self)
        let resourcePath = bundle.resourcePath! + "/ShareThatTo_ShareThatToTests.bundle/Fixtures/vertical-backup.mp4"
        
        let resourceURL = URL(fileURLWithPath: resourcePath)
        let avurl = AVURLAsset(url: resourceURL)
        
        let expectation = XCTestExpectation(description: "Thumbnail generated")

        avurl.thumbnail { (img) in
            XCTAssert(img !== nil)
            let attachment = XCTAttachment(image: img!)
            attachment.lifetime = .keepAlways
            self.add(attachment)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    // TODO: I'm not sure this is actually creating the right time based on the image attachments
    func testGeneratesThumbnailAtTime() {
        let bundle = Bundle(for: AVURLAssetTest.self)
        let resourcePath = bundle.resourcePath! + "/ShareThatTo_ShareThatToTests.bundle/Fixtures/vertical-backup.mp4"
        
        let resourceURL = URL(fileURLWithPath: resourcePath)
        let avurl = AVURLAsset(url: resourceURL)
        
        let expectation = XCTestExpectation(description: "Thumbnail generated")

        avurl.thumbnail(at: TimeInterval.init(0)) { (img) in
            XCTAssert(img !== nil)
            let attachment = XCTAttachment(image: img!)
            attachment.lifetime = .keepAlways
            self.add(attachment)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    static var allTests = [
        ("testGeneratesThumbnail", testGeneratesThumbnail),
        ("testGeneratesThumbnailAtTime", testGeneratesThumbnailAtTime),
    ]
}
