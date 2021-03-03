//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/3/21.
//
import UIKit
import Foundation

struct More: ShareOutletProtocol {
    static let imageName = "More"
    static let outletName = "More"
    static let canonicalOutletName = "more"
    static let requirements: ShareOutletRequirementProtocol = NoRequirements()

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
        
        let linkPreviewUsed = content.linkPreviewAvailable()
        let activityViewController =  UIActivityViewController(activityItems: [content.text(), content.videoURL], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = {(activityType, completed, returnedItems, error) in
            if (completed) {
                //
                delegate?.success(shareOutlet: self, strategiesUsed: (linkPreviewUsed ? [.raw, .linkPreview] : [.raw]))
            } else {
                delegate?.cancelled(shareOutlet: self)
            }
        }
        viewController.present(activityViewController, animated: true) {}
    }
}
