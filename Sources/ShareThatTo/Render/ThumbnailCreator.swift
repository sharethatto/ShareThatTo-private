//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/7/21.
//

import AVKit
import Foundation

class ThumbnailCreator
{
    internal static func thumbnail(videoURL: URL, completion: @escaping (Result<Data, Swift.Error>) -> Void)
    {
        let avurl = AVURLAsset(url: videoURL)
        avurl.thumbnail { (image) in
            guard let image = image else { return completion(.failure(NSError(domain: "ShareThatTo.VideoContent", code: 2, userInfo: ["reason": "Unable to create thumbnail"])))}
            guard let jpegData = image.jpegData(compressionQuality: 0.8) else { return  completion(.failure(NSError(domain: "ShareThatTo.VideoContent", code: 2, userInfo: ["reason": "Unable to create thumbnail"])))}
            completion(.success(jpegData))
        }
    }
}
