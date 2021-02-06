//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/3/21.
//

import UIKit
//import Foundation
//
//struct InstagramStories: ShareOutlet {
//    var delegate: ShareOutletDelegate?
//    let imageName = "InstagramStories"
//    let outlateName = "Stories"
//    
//    func share(shareable: ShareableContentWrapper, viewController: UIViewController) {
//        guard let unwrappedRawData = shareable.rawData else {
//            delegate?.failure(error: "Video unavailable")
//            return
//        }
//        
//        DispatchQueue.main.async {
//            let pasteboardItems = [//"com.instagram.sharedSticker.stickerImage": image,
//                               "com.instagram.sharedSticker.backgroundTopColor" : "#FFFFFF",
//                               "com.instagram.sharedSticker.backgroundBottomColor" : "#FFFFFF",
//                                "com.instagram.sharedSticker.backgroundVideo": unwrappedRawData,
//                               "com.instagram.sharedSticker.contentURL": "https://sharethatto-demo.s3.us-east-2.amazonaws.com/index.html"] as [String : Any]
//            let pasteboardOptions = [UIPasteboard.OptionsKey.expirationDate : NSDate().addingTimeInterval(60 * 5)]
//            UIPasteboard.general.setItems([pasteboardItems], options: pasteboardOptions)
//            UIApplication.shared.open(URL(string: "instagram-stories://share")!, options: [:], completionHandler: { (success) in
//                delegate?.success()
//            })
//        }
//    }
//}
