//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/3/21.
//

//import MessageUI
//import UIKit
//import Foundation
//
//class IMessageShareOutlet: NSObject, ShareOutlet, MFMessageComposeViewControllerDelegate {
//    var delegate: ShareOutletDelegate?
//    
//    let imageName = "IMessage"
//    let outlateName = "SMS"
//    func share(shareable: ShareableContentWrapper, viewController: UIViewController) {
//        // Do something with the delegate here
//        if MFMessageComposeViewController.canSendText() {
//            let composeViewController = MFMessageComposeViewController()
//            composeViewController.messageComposeDelegate = self
//            composeViewController.body = shareable.textRepresentation()
//
////            if MFMessageComposeViewController.canSendAttachments() {
////                let image = previewImage.image
////                let dataImage =  image!.pngData()
////                guard dataImage != nil else {
////                    return
////                }
////                composeViewController.addAttachmentData(dataImage!, typeIdentifier: "image/png", filename: "ImageData.png")
////            }
//            viewController.present(composeViewController, animated: true)
//        } else {
//            print("Can't send messages.")
//        }
//    }
//    
//    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
//        if result == .failed {
//            delegate?.failure(error: "could not send message")
//        }
//        else
//        {
//            delegate?.success()
//        }
//    }
//}
