//
//  File.swift
//
//
//  Created by Brian Anglin on 2/3/21.
//
import UIKit
import Foundation

struct Twitter: ShareOutletProtocol {
    static let imageName = "Twitter"
    static let outletName = "Twitter"
    static let canonicalOutletName = "twitter"
    static let requirements: ShareOutletRequirementProtocol = {
        return InstgramStoriesRequirements()
    }()

    static var outletLifecycleDelegate: ShareThatToLifecycleDelegate?
    var delegate: ShareOutletDelegate?
    var content: Content
    
    init(content: Content)
    {
        self.content = content
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
    
    private func shareVideo(content: VideoContent, viewController: UIViewController)
    {
        // https://github.com/twitterdev/cards-player-samples/blob/master/player/page.html
        if (content.linkPreviewAvailable())
        {
            // text will have the link preview in it
            guard let message = content.text().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                self.delegate?.failure(shareOutlet: self, error: "Unable to share to Twitter right now.")
                return
            }
            
            if (ShareOutletUtils.isTwitterAppInstalled)
            {
                let urlFeed = "twitter://post?message=" + message
                openURL(twitterURL: urlFeed)
            }
            else
            {
                let urlFeed = "https://twitter.com/intent/tweet?text=" + message
                openURL(twitterURL: urlFeed)
            }
        } else {
            // TODO: Handle waiting before we redirect you
            self.delegate?.failure(shareOutlet: self, error: "Unable to share to Twitter right now.")
        }
    }
    
    private func openURL(twitterURL: String)
    {
        guard let url = URL(string: twitterURL) else {
            delegate?.failure(shareOutlet: self, error: "Unable to share to Twitter right now.")
           return
       }
       DispatchQueue.main.async {
           if UIApplication.shared.canOpenURL(url) {
               if #available(iOS 10.0, *) {
                   UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                    self.delegate?.success(shareOutlet: self)
                   })
               } else {
                   UIApplication.shared.openURL(url)
                   self.delegate?.success(shareOutlet: self)
               }
           } else {
                self.delegate?.failure(shareOutlet: self, error: "Unable to open twitter")
           }
       }
    }
}
