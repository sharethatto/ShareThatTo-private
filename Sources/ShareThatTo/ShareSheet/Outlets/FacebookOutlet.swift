//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/10/21.
//

import UIKit
import Foundation
import FacebookCore
import FacebookShare

class FacebookOutletLifecycle: ShareThatToLifecycleDelegate
{
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool
    {
        ApplicationDelegate.shared.application(
                  app,
                  open: url,
                  sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                  annotation: options[UIApplication.OpenURLOptionsKey.annotation]
              )
    }
}


class Facebook: NSObject, ShareOutletProtocol
{

    
    static var outletLifecycleDelegate: ShareThatToLifecycleDelegate?  = {
        return FacebookOutletLifecycle()
    }()
    
    static let imageName = "Facebook"
    static let outletName = "Facebook"
    static let outletAnalyticsName = "facebook"
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
            if (!ShareOutletUtils.isFacebookAppInstalled) {
                // TODO: We can do this if we have the preview link.
                // We can use the link share strategy as a fallback if we need to
                // We can also use re-tar or even a native redirect preparation page before redirecting to fb
                // let url = URL(string: "https://www.facebook.com/dialog/share?app_id=1926440290830565&href=https://sharethatto-sdk.herokuapp.com/s/4cff8157b895b53737de241c5d8ff13c&redirect_uri=https://example.com")!
                // UIApplication.shared.openURL(url)
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
            delegate?.failure(error: "Invalid content type")
            return
        }
        shareVideo(content: videoContent, viewController: viewController)
    }
    
    
    weak var viewController: UIViewController?
    private func shareVideo(content: VideoContent, viewController: UIViewController)
    {
        // Prefer link strategy
        self.viewController = viewController
        let photoPermissionHelper = PhotoPermissionHelper.init(viewController: viewController, content: content, shareOutlet: self, delegate: self)
        photoPermissionHelper.requestPermission()
        

    }
    
    func shareVideoAsset(asset: PHAsset)
    {
        let shareVideo = ShareVideo(videoAsset: asset)
        let shareVdieoContent = ShareVideoContent()
        shareVdieoContent.video = shareVideo
        
        guard let viewController = self.viewController else {  delegate?.failure(error: "Unable to save video to share to Facebook."); return }
        let shareDialog = ShareDialog.init(fromViewController: viewController, content: shareVdieoContent, delegate: self)
        
        // I think validate needs to be on the main thread--definitely one of the two does
        DispatchQueue.main.async {
            do {
                try shareDialog.validate()
            } catch let error {
                print(error)
                // Ideally we should never trigger this, b/c we should have caught the error
                // at the top where we decided if we could show the outlet or not.
                self.delegate?.failure(error: "Whoops! We can't share to Facebook right now.")
                // TODO: Capture the error here
                return
            }
            shareDialog.show()
        }
    }
}


extension Facebook: PhotoPermissionHelperDelegate
{
    func succeeded()
    {
        // video content
        guard let videoContent = content.videoContent() else {
            delegate?.failure(error: "Unable to save video to share to Facebook.")
            return
        }
        
        // Now we actually need to do the share
        var placeholder: PHObjectPlaceholder?
        PHPhotoLibrary.shared().performChanges {
            let changeRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoContent.videoURL)
            placeholder =  changeRequest?.placeholderForCreatedAsset
        } completionHandler: { (success, error) in
            if (success) {
                guard let placeholder = placeholder else { self.delegate?.failure(error: "Unable to save video to share to Facebook."); return }
                
                let result = PHAsset.fetchAssets(withLocalIdentifiers: [placeholder.localIdentifier], options: nil)
                guard let asset = result.firstObject else { self.delegate?.failure(error: "Unable to save video to share to Facebook."); return }
                self.shareVideoAsset(asset: asset)
            } else {
                self.delegate?.failure(error: "Unable to save video to share to Facebook.")
            }
        }
    }
    
    func cancelled()
    {
        delegate?.cancelled()
    }
    
    func failed()
    {
        // We've already communicated with the user so this ins't really "failing" in the same way
        delegate?.cancelled()
    }
    
    
}

extension Facebook: SharingDelegate
{
    func sharer(_ sharer: Sharing, didCompleteWithResults results: [String : Any])
    {
        delegate?.success()
    }
    
    func sharer(_ sharer: Sharing, didFailWithError error: Error)
    {
        delegate?.failure(error: error.localizedDescription)
    }
    
    func sharerDidCancel(_ sharer: Sharing)
    {
        delegate?.cancelled()
    }
}
