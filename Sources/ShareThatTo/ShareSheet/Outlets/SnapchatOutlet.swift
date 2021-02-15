//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/12/21.
//

import UIKit
import Foundation
//import SCSDKCoreKit
//import SCSDKCreativeKit

// TODO: [Re-enable snapchat] Change to public
internal protocol SnapchatOutletProtocol {
    init(delegate: ShareOutletDelegate)
    func shareVideo(videoURL: URL)
    func shareImage(image: UIImage)
}

class Snapchat: NSObject, ShareOutletProtocol
{
    required init(content: Content) {
        self.content = content
    }    
    
    static let imageName = "Snapchat"
    static let outletName = "Snapchat"
    static let outletAnalyticsName = "snapchat"

    static var outletLifecycleDelegate: ShareThatToLifecycleDelegate?
    var delegate: ShareOutletDelegate?
    var content: Content
    
    // Right now we can only perform with video content
    static func canPerform(withContent content: Content) -> Bool
    {
        if (content.contentType == .video)
        {
            return (ShareThatTo.shared.snapchatShare != nil)
        }
        return false
    }
    
    func share(with viewController: UIViewController)
    {
        // We only support video content
        guard let videoContent: VideoContent = self.content.videoContent() else {
            delegate?.failure(error: "Invalid content type")
            return
        }
        shareVideo(content: videoContent, viewController: viewController)
    }

    var viewController: UIViewController?
    private func shareVideo(content: VideoContent, viewController: UIViewController)
    {
        self.viewController = viewController

        guard let snapchatShareClass = ShareThatTo.shared.snapchatShare else {
            self.delegate?.failure(error: "Unable to share to Snapchat right now.")
            return
        }
        let snapchatShare = snapchatShareClass.init(delegate: self)
        DispatchQueue.main.async {
            viewController.view.isUserInteractionEnabled = false
            snapchatShare.shareVideo(videoURL: content.videoURL)
        }
    }
}

extension Snapchat: ShareOutletDelegate
{
    func success() {
        guard let viewController = viewController else {
            self.delegate?.success()
            return
        }
        DispatchQueue.main.async { viewController.view.isUserInteractionEnabled = true }
        self.delegate?.success()
    }
    
    func failure(error: String) {
        guard let viewController = viewController else {
            self.delegate?.failure(error: error)
            return
        }
        DispatchQueue.main.async { viewController.view.isUserInteractionEnabled = true }
        self.delegate?.failure(error: error)
    }
    
    func cancelled() {
        guard let viewController = viewController else {
            self.delegate?.cancelled()
            return
        }
        DispatchQueue.main.async { viewController.view.isUserInteractionEnabled = true }
        self.delegate?.cancelled()
    }
}
