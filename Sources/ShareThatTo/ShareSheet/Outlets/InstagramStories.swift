//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/3/21.
//

import UIKit
import Foundation


struct InstagramStories: ShareOutletProtocol
{
    static var outletLifecycleDelegate: ShareThatToLifecycleDelegate?
    
    static let imageName = "InstagramStories"
    static let outletName = "Stories"
    static let canonicalOutletName = "instagram-stories"
    static let requirements: ShareOutletRequirementProtocol = {
        return InstgramStoriesRequirements()
    }()
    
    var delegate: ShareOutletDelegate?
    var content: Content
    
    init(content: Content)
    {
        self.content = content
    }
    
    static func canPerform(withContent content: Content) -> Bool
    {
        // TODO: Refactor this to not need ios 10
        if #available(iOS 10.0, *) {
            return content.contentType == .video
        }
        return false
    }

    func share(with viewController: UIViewController)
    {
        // We only support video content
        guard let videoContent: VideoContent = content.videoContent() else {
            delegate?.failure(shareOutlet: self, error: "Invalid content type")
            return
        }
        shareVideo(content: videoContent, viewController: viewController)
    }
    
    private func shareVideo(content: VideoContent, viewController: UIViewController)
    {
        let rawShareStrategy = content.rawStrategy(caller: self)
        if #available(iOS 10.0, *) {
            DispatchQueue.main.async {
            var pasteboardItems = [//"com.instagram.sharedSticker.stickerImage": image,
                               "com.instagram.sharedSticker.backgroundTopColor" : "#FFFFFF",
                               "com.instagram.sharedSticker.backgroundBottomColor" : "#FFFFFF",
                                "com.instagram.sharedSticker.backgroundVideo": rawShareStrategy.data] as [String: Any]
                
                let ctaLink = content.ctaLink()?.absoluteString ?? ""
                if (ctaLink != "") {
                    pasteboardItems["com.instagram.sharedSticker.contentURL"] = ctaLink
                }
                let pasteboardOptions = [UIPasteboard.OptionsKey.expirationDate : NSDate().addingTimeInterval(60 * 5)]
       
            UIPasteboard.general.setItems([pasteboardItems], options: pasteboardOptions)
            UIApplication.shared.open(URL(string: "instagram-stories://share")!, options: [:], completionHandler: { (success) in
                delegate?.success(shareOutlet: self)
            })
            }
        } else {
            delegate?.failure(shareOutlet: self, error: "Needs iOS 10")
        }
    }
}
