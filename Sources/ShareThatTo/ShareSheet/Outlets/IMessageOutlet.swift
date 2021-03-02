//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/3/21.
//

import MessageUI
import UIKit
import Foundation

class IMessage: NSObject, ShareOutletProtocol, MFMessageComposeViewControllerDelegate
{
    static var outletLifecycleDelegate: ShareThatToLifecycleDelegate?
    
    static let imageName = "IMessage"
    static let outletName = "SMS"
    static let canonicalOutletName = "imessage"
    static let requirements: ShareOutletRequirementProtocol = {
        return NoRequirements()
    }()
    
    var delegate: ShareOutletDelegate?
    var content: Content
    
    required init(content: Content)
    {
        self.content = content
    }

    // Make sure we have the ability to send messages before we show this option
    static func canPerform(withContent content: Content) -> Bool
    {
        if (content.contentType == .video)
        {
            return MFMessageComposeViewController.canSendText() && MFMessageComposeViewController.canSendAttachments()
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

    var linkUsed = true
    var viewController: UIViewController?
    func shareVideo(content: VideoContent, viewController: UIViewController)
    {
        self.viewController = viewController
        let composeViewController = MFMessageComposeViewController()
        composeViewController.messageComposeDelegate = self
        composeViewController.body = content.text()
        if (!content.linkPreviewAvailable())
        {
            linkUsed = false
            let rawShareStrategy = content.rawStrategy(caller: self)
            composeViewController.addAttachmentData(rawShareStrategy.data, typeIdentifier: "public.movie", filename: "movie.mp4")
        }
        viewController.present(composeViewController, animated: true)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        print("[ShareThatTo] RESULT \(result)")
        
        switch(result) {
            case .failed:
                delegate?.failure(shareOutlet: self, error: "Could not send message")
            case .sent:
                delegate?.success(shareOutlet: self, strategiesUsed: (linkUsed ? [.linkPreview] : [.raw]))
            case .cancelled:
                if let vc = self.viewController{
                    vc.dismiss(animated: true, completion: nil)
                }
                
                delegate?.cancelled(shareOutlet:self)
        @unknown default:
            delegate?.failure(shareOutlet: self, error: "Could not send message")
        }
    }
}
