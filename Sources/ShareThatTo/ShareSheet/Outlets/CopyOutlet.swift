//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/3/21.
//

import UIKit
import Foundation

struct Copy: ShareOutletProtocol
{
    static var outletLifecycleDelegate: ShareThatToLifecycleDelegate?
    
    static let imageName = "Copy"
    static let outletName = "Copy"
    static let outletAnalyticsName = "copy"
    var delegate: ShareOutletDelegate?
    var content: Content
    
    init(content: Content)
    {
        self.content = content
    }
    
    func share(with viewController: UIViewController)
    {
        // We only support video content
        guard let videoContent: VideoContent = content.videoContent() else {
            delegate?.failure(self, error: "Invalid content type")
            return
        }
        shareVideo(content: videoContent, viewController: viewController)
    }
    
    private func shareVideo(content: VideoContent, viewController: UIViewController)
    {
        let text = content.text()
        let pb = UIPasteboard.general
        pb.string = text
        let rawShareStrategy = content.rawStrategy(caller: self)
        pb.setData(rawShareStrategy.data, forPasteboardType: "public.mpeg-4")
        delegate?.success(self)
    }
}
