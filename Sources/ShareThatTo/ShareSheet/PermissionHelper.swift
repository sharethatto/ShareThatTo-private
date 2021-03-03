//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/12/21.
//

import UIKit
import Photos
import Foundation

public protocol PhotoPermissionHelperDelegate
{
    func succeeded()
    func cancelled()
    func failed()
}


class PhotoPermissionHelper
{
    let viewController: UIViewController
    let content: Content
    let shareOutlet: ShareOutletProtocol
    var delegate: PhotoPermissionHelperDelegate?
    
    public init(viewController: UIViewController, content: Content, shareOutlet: ShareOutletProtocol, delegate: PhotoPermissionHelperDelegate?)
    {
        self.viewController = viewController
        self.content = content
        self.shareOutlet = shareOutlet
        self.delegate = delegate
    }
    
    func requestPermission()
    {
        // Do we have the permission we need?
        let result = PHPhotoLibrary.authorizationStatus()
        switch (result) {
        case .authorized, .limited: delegate?.succeeded(); return
        case .notDetermined: actuallyRequestPermission()
        default: presentSettingsRedirect()
        }
    }
    
    private func presentSettingsRedirect()
    {
        let avc = UIAlertController(title: "Looks like you've denied permissions to save this \(content.contentType).", message: "To share to \(type(of: shareOutlet).outletName) we need to save content to your Photos first. Would you like to change your settings? ", preferredStyle: .alert)
        avc.addAction(UIAlertAction(title: "No, Thanks", style: .default, handler: { (action) in
            self.delegate?.cancelled()
        }))
        avc.addAction(UIAlertAction(title: "Yes, Please!", style: .default, handler: { (action) in
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { self.delegate?.failed(); return }
            self.delegate?.cancelled() // This isn't the perfect description but it's close enough, could add a "redirectedToSettings" instead
            UIApplication.shared.open(settingsURL)
        }))
        self.viewController.present(avc, animated: true, completion: nil)
    }
    
    private func actuallyRequestPermission()
    {
        let avc = UIAlertController(title: "Allow us to save this \(content.contentType)?", message: "To share to \(type(of: shareOutlet).outletName) we need to save content to your Photos first", preferredStyle: .alert)
        avc.addAction(UIAlertAction(title: "No, Thanks", style: .default, handler: { (action) in
            self.delegate?.cancelled()
        }))
        avc.addAction(UIAlertAction(title: "Yes, Please!", style: .default, handler: { (action) in
            // Actually prompt the permission
            PHPhotoLibrary.requestAuthorization { (result) in
                switch (result) {
                case .authorized, .limited: self.delegate?.succeeded()
                default: self.delegate?.failed()
                }
            }
        }))
        self.viewController.present(avc, animated: true, completion: nil)
    }
}
