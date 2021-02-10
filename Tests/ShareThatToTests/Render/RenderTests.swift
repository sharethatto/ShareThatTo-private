//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/9/21.
//

import Foundation

import XCTest
@testable import ShareThatTo

final class RenderTests: XCTestCase {
    
    static func getRender() -> RenderProtocol
    {
        return Render()
    }
    
    func testRenderProducesThumbnailAndVideo()
    {
        // Recording: Terminate server before testing
        let expectation = self.expectation(description: "Render")
        
        let render = RenderTests.getRender()
        let video = TestHelpers.fixtureBundle
        
        // TODO: Do something to deal with handling scheme
        let url = URL(string: "file://" + video.path(forResource: "vertical-backup", ofType: "mp4")!)!
        render.renderThumbnailAndVideo(videoURL: url) {
            (result) in
            switch(result){
            case .failure: XCTAssert(false)
            case .success(let datas):
                // Not sure what exactly to test here
                XCTAssert(datas.0.count < datas.1.count )
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }
    
    static var allTests = [
        ("testRenderProducesThumbnailAndVideo", testRenderProducesThumbnailAndVideo),
    ]
}
