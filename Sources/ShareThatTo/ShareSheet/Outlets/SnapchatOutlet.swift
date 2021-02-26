//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/12/21.
//

import UIKit
import Foundation


// TODO: [Re-enable snapchat] Change to public
//internal protocol SnapchatOutletProtocol {
//    init(delegate: ShareOutletDelegate)
//    func shareVideo(videoURL: URL)
//    func shareImage(image: UIImage)
//}
#if canImport(SCSDKCreativeKit)
import SCSDKCreativeKit
#endif

//protocol SnapchatAvailabilityProxyProtocol
//{
//
//}

class SnapchatAvailabilityProxy
{
    public init() {}
    #if canImport(SCSDKCreativeKit)

    fileprivate lazy var snapAPI = {
        return SCSDKSnapAPI()
    }()
    static func available() -> Bool {
        return true
    }
    func shareVideo(videoURL: URL, shareOutlet: ShareOutletProtocol)
    {
        let video = SCSDKSnapVideo(videoUrl: videoURL)
        let content = SCSDKVideoSnapContent(snapVideo: video)
        snapAPI.startSending(content) { (error) in
            guard let error = error else {
                shareOutlet.delegate?.success(shareOutlet: shareOutlet)
                return
            }
            Analytics.shared.addObservabilityEvent(event: ObservabilityEvent(event_name: "share_outlet.snapchat.failure", message: error.localizedDescription))
            shareOutlet.delegate?.failure(shareOutlet: shareOutlet, error: "Unable to send Snap right now.")
            print(error)
        }
    }
    
    
    #else
    static func available() -> Bool {
        return false
    }
    func shareVideo(videoURL: URL, shareOutlet: ShareOutletProtocol) {
        shareOutlet.delegate?.failure(shareOutlet: shareOutlet, error: "Unable to send Snap right now.")
    }
    #endif
}

class Snapchat: NSObject, ShareOutletProtocol
{
    required init(content: Content) {
        self.content = content
    }    
    
    static let imageName = "Snapchat"
    static let outletName = "Snapchat"
    static let canonicalOutletName = "snapchat"
    static let requirements: ShareOutletRequirementProtocol = {
        return SnapchatRequirements(snapchatClientKey: "")
    }()

    static var outletLifecycleDelegate: ShareThatToLifecycleDelegate?
    var delegate: ShareOutletDelegate?
    var content: Content
    
    
    private let availabilityProxy: SnapchatAvailabilityProxy = {
       return SnapchatAvailabilityProxy()
    }()
    
    // Right now we can only perform with video content
    static func canPerform(withContent content: Content) -> Bool
    {
        if (content.contentType == .video)
        {
            return SnapchatAvailabilityProxy.available()
        }
        return false
    }
    
    func share(with viewController: UIViewController)
    {
        // We only support video content
        guard let videoContent: VideoContent = self.content.videoContent() else {
            delegate?.failure(shareOutlet: self, error: "Invalid content type")
            return
        }
        shareVideo(content: videoContent, viewController: viewController)
    }
    
    


    var viewController: UIViewController?
    private func shareVideo(content: VideoContent, viewController: UIViewController)
    {
        availabilityProxy.shareVideo(videoURL: content.videoURL, shareOutlet: self)
    }
}

//    fileprivate lazy var snapAPI = {
//        return SCSDKSnapAPI()
//    }()


