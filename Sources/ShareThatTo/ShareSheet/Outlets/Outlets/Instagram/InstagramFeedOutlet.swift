//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/13/21.
//
import UIKit
import Photos
import Foundation

struct InstagramFeed: ShareOutletProtocol
{
    static var outletLifecycleDelegate: ShareThatToLifecycleDelegate?
    
    static let imageName = "InstagramFeed"
    static let outletName = "Instagram"
    static let canonicalOutletName = "instagram-feed"
    static let requirements: ShareOutletRequirementProtocol = InstagramFeedRequirements()
    
    var delegate: ShareOutletDelegate?
    var content: Content
    
    init(content: Content)
    {
        self.content = content
    }
    
    static func canPerform(withContentType contentType:ContentType) -> Bool
    {
        if (!ShareOutletUtils.isInstagramAppInstalled) {
            return false
        }
        // TODO: Refactor this to not need ios 10
        return contentType == .video
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
        let photoPermissionHelper = PhotoPermissionHelper.init(viewController: viewController, content: content, shareOutlet: self, delegate: self)
        photoPermissionHelper.requestPermission()
    }
    
    func shareVideoAsset(asset: PHAsset)
    {
        let localIdentifier = asset.localIdentifier
        let urlFeed = "instagram://library?LocalIdentifier=" + localIdentifier
        guard let url = URL(string: urlFeed) else {
            delegate?.failure(shareOutlet: self, error: "Unable to save video to share to Instagram.")
           return
       }
       DispatchQueue.main.async {
           if UIApplication.shared.canOpenURL(url) {
               if #available(iOS 10.0, *) {
                   UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                    self.delegate?.success(shareOutlet: self, strategiesUsed: [.raw])
                   })
               } else {
                   UIApplication.shared.openURL(url)
                    self.delegate?.success(shareOutlet: self, strategiesUsed:[.raw])
               }
           } else {
                self.delegate?.failure(shareOutlet: self, error: "Unable to open instagram")
           }
       }
    }
}


extension InstagramFeed: PhotoPermissionHelperDelegate
{
    func succeeded()
    {
        // video content
        guard let videoContent = content.videoContent() else {
            delegate?.failure(shareOutlet: self, error: "Unable to save video to share to Instagram.")
            return
        }
        
        // Now we actually need to do the share
        var placeholder: PHObjectPlaceholder?
        PHPhotoLibrary.shared().performChanges {
            let changeRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoContent.videoURL)
            placeholder =  changeRequest?.placeholderForCreatedAsset
        } completionHandler: { (success, error) in
            if (success) {
                guard let placeholder = placeholder else { self.delegate?.failure(shareOutlet: self, error: "Unable to save video to share to Instagram."); return }
                
                let result = PHAsset.fetchAssets(withLocalIdentifiers: [placeholder.localIdentifier], options: nil)
                guard let asset = result.firstObject else { self.delegate?.failure(shareOutlet: self, error: "Unable to save video to share to Instagram."); return }
                self.shareVideoAsset(asset: asset)
            } else {
                self.delegate?.failure(shareOutlet: self, error: "Unable to save video to share to Instagram.")
            }
        }
    }
    
    func cancelled()
    {
        delegate?.cancelled(shareOutlet: self)
    }
    
    func failed()
    {
        // We've already communicated with the user so this ins't really "failing" in the same way
        delegate?.cancelled(shareOutlet: self)
    }
}
