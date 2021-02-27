//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/12/21.
//

import UIKit
import Foundation
import FacebookCore
import FacebookShare

// TODO: Refactor this and the facebook outlet into one class 
class Messenger: NSObject, ShareOutletProtocol
{
    static var outletLifecycleDelegate: ShareThatToLifecycleDelegate?
    
    static let imageName = "Messenger"
    static let outletName = "Messenger"
    static let canonicalOutletName = "messenger"
    static let requirements: ShareOutletRequirementProtocol = {
        return FacebookRequirements(facebookAppId: "")
    }()
    
    var delegate: ShareOutletDelegate?
    var content: Content
    
    required init(content: Content)
    {
        self.content = content
    }
    
    // Right now we can only perform with video content
    static func canPerform(withContent content: Content) -> Bool
    {

        if (content.contentType == .video)
        {
            if (!ShareOutletUtils.isMessengerAppInstalled) {
                // TODO: We can do this if we have the preview link.
                // We can use the link share strategy as a fallback if we need to
                // We can also use re-tar or even a native redirect preparation page before redirecting to fb
                // let url = URL(string: "https://www.Messenger.com/dialog/share?app_id=1926440290830565&href=https://sharethatto-sdk.herokuapp.com/s/4cff8157b895b53737de241c5d8ff13c&redirect_uri=https://example.com")!
                // UIApplication.shared.openURL(url)
                // If we do this, we MUST change the strategiesUsed: in the success delegate
                return false
            }
            return true
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
    
    
    weak var viewController: UIViewController?
    private func shareVideo(content: VideoContent, viewController: UIViewController)
    {
        self.viewController = viewController
        let photoPermissionHelper = PhotoPermissionHelper.init(viewController: viewController, content: content, shareOutlet: self, delegate: self)
        photoPermissionHelper.requestPermission()
    }
    
    func shareVideoAsset(asset: PHAsset)
    {
        let shareVideo = ShareVideo(videoAsset: asset)
        let shareVdieoContent = ShareVideoContent()
        shareVdieoContent.video = shareVideo
        
        let shareDialog = MessageDialog.init(content: shareVdieoContent, delegate: self)

        
        // I think validate needs to be on the main thread--definitely one of the two does
        DispatchQueue.main.async {
            do {
                try shareDialog.validate()
            } catch let error {
                print(error)
                // Ideally we should never trigger this, b/c we should have caught the error
                // at the top where we decided if we could show the outlet or not.
                self.delegate?.failure(shareOutlet: self, error: "Whoops! We can't share to Messenger right now.")
                // TODO: Capture the error here
                return
            }
            shareDialog.show()
        }
    }
}


extension Messenger: PhotoPermissionHelperDelegate
{
    func succeeded()
    {
        // video content
        guard let videoContent = content.videoContent() else {
            delegate?.failure(shareOutlet: self, error: "Unable to save video to share to Messenger.")
            return
        }
        
        // Now we actually need to do the share
        var placeholder: PHObjectPlaceholder?
        PHPhotoLibrary.shared().performChanges {
            let changeRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoContent.videoURL)
            placeholder =  changeRequest?.placeholderForCreatedAsset
        } completionHandler: { (success, error) in
            if (success) {
                guard let placeholder = placeholder else { self.delegate?.failure(shareOutlet: self, error: "Unable to save video to share to Messenger."); return }
                
                let result = PHAsset.fetchAssets(withLocalIdentifiers: [placeholder.localIdentifier], options: nil)
                guard let asset = result.firstObject else { self.delegate?.failure(shareOutlet: self, error: "Unable to save video to share to Messenger."); return }
                self.shareVideoAsset(asset: asset)
            } else {
                self.delegate?.failure(shareOutlet: self, error: "Unable to save video to share to Messenger.")
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

extension Messenger: SharingDelegate
{
    func sharer(_ sharer: Sharing, didCompleteWithResults results: [String : Any])
    {
        delegate?.success(shareOutlet: self, strategiesUsed: [.raw])
    }
    
    func sharer(_ sharer: Sharing, didFailWithError error: Error)
    {
        delegate?.failure(shareOutlet: self, error: error.localizedDescription)
    }
    
    func sharerDidCancel(_ sharer: Sharing)
    {
        delegate?.cancelled(shareOutlet: self)
    }
}
