//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/12/21.
//

import UIKit
import Photos
import Foundation

struct Download: ShareOutletProtocol
{
    static var outletLifecycleDelegate: ShareThatToLifecycleDelegate?
    
    static let imageName = "Download"
    static let outlateName = "Download"
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
            delegate?.failure(error: "Invalid content type")
            return
        }
        shareVideo(content: videoContent, viewController: viewController)
    }
    
    private func shareVideo(content: VideoContent, viewController: UIViewController)
    {
        // Prefer link strategy
        let photoPermissionHelper = PhotoPermissionHelper.init(viewController: viewController, content: content, shareOutlet: self, delegate: self)
        photoPermissionHelper.requestPermission()
    }
}


extension Download: PhotoPermissionHelperDelegate
{
    func succeeded()
    {
        // video content
        guard let videoContent = content.videoContent() else {
            delegate?.failure(error: "Unable to save video.")
            return
        }
        
        // Now we actually need to do the share
        var placeholder: PHObjectPlaceholder?
        PHPhotoLibrary.shared().performChanges {
            let changeRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoContent.videoURL)
            placeholder =  changeRequest?.placeholderForCreatedAsset
        } completionHandler: { (success, error) in
            if (success) {
                guard let placeholder = placeholder else { self.delegate?.failure(error: "Unable to save video."); return }
                
                let result = PHAsset.fetchAssets(withLocalIdentifiers: [placeholder.localIdentifier], options: nil)
                guard let asset = result.firstObject else { self.delegate?.failure(error: "Unable to save video."); return }
                self.delegate?.success()
            } else {
                self.delegate?.failure(error: "Unable to save video.")
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
