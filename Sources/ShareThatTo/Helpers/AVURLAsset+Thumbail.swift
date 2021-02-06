//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/3/21.
//

import AVKit
import Foundation

extension AVURLAsset {
    func thumbnail(at time: TimeInterval,  completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let assetIG = AVAssetImageGenerator(asset: self)
            assetIG.appliesPreferredTrackTransform = true
            assetIG.apertureMode = AVAssetImageGenerator.ApertureMode.encodedPixels

            let cmTime = CMTime(seconds: time, preferredTimescale: 60)
            let thumbnailImageRef: CGImage
            do {
                thumbnailImageRef = try assetIG.copyCGImage(at: cmTime, actualTime: nil)
            } catch let error {
                print("Error: \(error)")
                return completion(nil)
            }

            DispatchQueue.main.async {
                completion(UIImage(cgImage: thumbnailImageRef))
            }
        }
    }
    func thumbnail(completion: @escaping (UIImage?) -> Void) {
        thumbnail(at: TimeInterval.init(0), completion: completion)
    }
}

