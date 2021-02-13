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
    static let outlateName = "More"

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
            delegate?.failure(error: "Invalid content type")
            return
        }
        shareVideo(content: videoContent, viewController: viewController)
    }
    
    private func shareVideo(content: VideoContent, viewController: UIViewController)
    {
        
        let activityViewController =  UIActivityViewController(activityItems: [content.text(), content.videoURL], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = {(activityType, completed, returnedItems, error) in
            if (completed) {
                delegate?.success()
            } else {
                delegate?.cancelled()
            }
        }
        viewController.present(activityViewController, animated: true) {}
    }
}
