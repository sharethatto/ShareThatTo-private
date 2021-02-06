//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/3/21.
//

import AVKit
import Foundation

class VideoContent: Content {
    let contentType: ContentType = .video
    var contentPreparation: ContentPreparation = .notStarted
    
//    let videoData: NSData!
    let videoURL: URL
    
    
//    func link() -> URL {
//        
//    }
    
    init(videoURL: URL) {
        self.videoURL = videoURL
    }
    
    func prepare() {
        let avurl = AVURLAsset(url: videoURL)
        avurl.thumbnail { (image) in
            let jpegData = image?.jpegData(compressionQuality: 0.8)
            
            // Upload image over network
            
        }
        // Prepare representations
        // We have about 4 seconds.. not great
        
        // -> Upload image
    }
    
   
    
    
}
