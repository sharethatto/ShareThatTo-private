//
//  File.swift
//
//
//  Created by Brian Anglin on 2/6/21.
//


import XCTest
@testable import ShareThatTo

final class NetworkTests: XCTestCase {
    func testRequestShare()
    {
//        ShareThatTo.configure(apiKey: "share_pk_5d167039aee692d93a1821b38ac58c6b")
        let expectation = self.expectation(description: "Network Request")
        let bundle = Bundle(for: AVURLAssetTest.self)
        let fixturesPath = bundle.resourcePath! + "/ShareThatTo_ShareThatToTests.bundle/Fixtures/"
        
        
        let videoURL = URL(fileURLWithPath: fixturesPath + "/vertical-backup.mp4")
        let videoData: Data
        do {
            videoData = try Data(contentsOf: videoURL)
       
            
            let image = UIImage(contentsOfFile: fixturesPath + "/thumbnail.png")
            let imageData = image?.jpegData(compressionQuality: 0.8)
            
            let shareable = ShareableRequest(title: "Check this out!", shareable_type: "video")
            let shareRequest = ShareRequest(video_content: videoData.uploadPlan(contentType: "video/mp4"), preview_image: (imageData?.uploadPlan(contentType: "image/jpeg"))!, shareable: shareable)
            Network.shared.shareRequest(share: shareRequest) { (result) in
                switch(result) {
                case .success(let response):
//                    XCTAssertNotNil(response.preview_image.configurable?.direct_upload?.url)
//                    XCTAssertNotNil(response.video_content.configurable?.direct_upload?.url)
                    XCTAssertNotNil(response.shareable.title)
                    XCTAssertNotNil(response.shareable.link)
                    XCTAssertNotNil(response.shareable.shareable_access_token)
                    XCTAssert(true)
                    
                    Network.shared.upload(plan: response.preview_image, data: imageData!) {
                        (result) in
                        switch(result) {
                        case .success(_):
                            Network.shared.activateShare(activate: ActivateRequest(video_content: false, preview_image: true, shareable_access_token: response.shareable.shareable_access_token)) {
                                (result) in
                                switch(result) {
                                case .success(_):
                                    XCTAssert(true)
                                    expectation.fulfill()
                                case .failure:
                                    XCTAssert(false)
                                }
                                
                            }
                        case .failure:
                            XCTAssert(false)
                        }
                        
                    }
                case .failure:
                    XCTAssert(false)
                }
            }
        } catch let error
        {
            XCTAssert(false)
        }
        wait(for: [expectation], timeout: 5.0)
    }
    
    
    func testRequestShareE2E()
    {
//        ShareThatTo.configure(apiKey: "share_pk_5d167039aee692d93a1821b38ac58c6b")
//        let expectation = self.expectation(description: "Network Request")
//        let bundle = Bundle(for: AVURLAssetTest.self)
//        let fixturesPath = bundle.resourcePath! + "/ShareThatTo_ShareThatToTests.bundle/Fixtures/"
//        
//        
//        let videoURL = URL(fileURLWithPath: fixturesPath + "/vertical-backup.mp4")
//        let videoData: Data
//        do {
//            videoData = try Data(contentsOf: videoURL)
//       
//            
//            let image = UIImage(contentsOfFile: fixturesPath + "/thumbnail.png")
//            let imageData = image?.jpegData(compressionQuality: 0.8)
//            
//            let shareable = ShareableRequest(title: "Check this out!", shareable_type: "video")
//            let shareRequest = ShareRequest(video_content: videoData.uploadPlan(contentType: "video/mp4"), preview_image: (imageData?.uploadPlan(contentType: "image/jpeg"))!, shareable: shareable)
//            
//            Network.shared.share(share: shareRequest, previewImage: imageData!, videoContent: videoData, shareRequestCompleted: {
//                (result) in
//                switch(result) {
//                case .success(let response):
//                    expectation.fulfill()
//                case .failure:
//                    XCTAssert(false)
//                    break
//                }
//            })
//        } catch let error {
//            print(error)
//        }
//        
//        wait(for: [expectation], timeout: 5.0)
    }

    static var allTests = [
        ("testRequestShare", testRequestShare),
    ]
}
