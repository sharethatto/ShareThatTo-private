//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/7/21.
//

import AVKit
import Foundation

internal class ThumbnailCreator
{
    public static func thumbnail(videoURL: URL, completion: @escaping (Result<Data, Swift.Error>) -> Void)
    {
        let avurl = AVURLAsset(url: videoURL)
        avurl.thumbnail { (image) in
            guard let thumbnail = image else {
                let error = NSError(domain: "ShareThatTo.VideoContent", code: 2, userInfo: ["reason": "Unable to create thumbnail"])
                return completion(.failure(error))
            }
            var renderedImage : UIImage?
            
            if let playButtonOverlay = UIImage(contentsOfFile: Bundle.module.path(forResource: "Assets/PlayButton", ofType: ".png")!) {
                
                let rect = CGRect(x: 0, y: 0, width: thumbnail.size.width, height: thumbnail.size.height)

                UIGraphicsBeginImageContextWithOptions(thumbnail.size, true, 0)
                guard let context = UIGraphicsGetCurrentContext() else {
                    guard let jpegData = thumbnail.jpegData(compressionQuality: 0.8) else {
                        let error = NSError(domain: "ShareThatTo.VideoContent", code: 2, userInfo: ["reason": "Unable to create thumbnail"])
                        return completion(.failure(error))
                    }
                    return completion(.success(jpegData))
                }

                context.setFillColor(UIColor.white.cgColor)
                context.fill(rect)

                thumbnail.draw(in: rect, blendMode: .normal, alpha: 1)
                playButtonOverlay.draw(in: CGRect(
                                        x: thumbnail.size.width/2-playButtonOverlay.size.width/2,
                                        y: thumbnail.size.height/2-playButtonOverlay.size.height/2,
                                        width: playButtonOverlay.size.width,
                                        height: playButtonOverlay.size.height),
                                       blendMode: .normal, alpha: 0.9)

                renderedImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
            }
            guard let outputImage = renderedImage else {
                guard let jpegData = thumbnail.jpegData(compressionQuality: 0.8) else {
                    let error = NSError(domain: "ShareThatTo.VideoContent", code: 2, userInfo: ["reason": "Unable to create thumbnail"])
                    return completion(.failure(error))
                }
                return completion(.success(jpegData))
            }
            guard let jpegData = outputImage.jpegData(compressionQuality: 0.8) else {
                let error = NSError(domain: "ShareThatTo.VideoContent", code: 2, userInfo: ["reason": "Unable to create thumbnail"])
                return completion(.failure(error))
            }

            completion(.success(jpegData))
        }
    }
}
