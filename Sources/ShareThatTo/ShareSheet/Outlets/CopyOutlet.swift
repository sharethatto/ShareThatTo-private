//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/3/21.
//

import UIKit
import Foundation

//struct Copy: ShareOutlet {
//    var delegate: ShareOutletDelegate?
//    
//    func share(content: Content, viewController: UIViewController) {
//        switch content.contentType {
//        case .unknown:
//            delegate?.failure(error: "Unknown content type")
//            return
//        case .video:
//            shareVideo(content: content as! VideoContent, viewController: viewController)
//            return
//        }
//    }
//    
//    private func shareVideo(content: VideoContent, viewController: UIViewController) {
//        let text = shareable.textRepresentation()
//        let pb = UIPasteboard.general
//        pb.string = text
//        guard let data = shareable.rawData else {
//            delegate?.failure(error: "Unable to copy video")
//            return
//        }
//        pb.setData(Data(referencing:  data), forPasteboardType: "public.mpeg-4")
//        delegate?.success()
//    }
//    
//    let imageName =  "Copy"
//    let outlateName = "Copy"
//}
