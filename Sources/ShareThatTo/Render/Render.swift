//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/7/21.
//

import Foundation

extension Render
{
    enum Error: LocalizedError
    {
        case unknown
        case thumbnail
        case video
        
        var errorDescription: String? {
            switch self
            {
            case .unknown: return NSLocalizedString("An unknown error occurred.", comment: "")
            case .thumbnail: return NSLocalizedString("Unable to export thumbnail file.", comment: "")
            case .video: return NSLocalizedString("Unable to export video file.", comment: "")
            }
        }
    }
}

protocol RenderProtocol {
    func renderThumbnailAndVideo(videoURL: URL, completion: @escaping (Result<(Data, Data), Swift.Error>) -> Void)
}

class Render: RenderProtocol
{
    public init() { }
    
    func renderThumbnailAndVideo(videoURL: URL, completion: @escaping (Result<(Data, Data), Swift.Error>) -> Void)
    {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        dispatchGroup.enter()
        
        var renderedThumbnail: Data?
        var renderedVideo: Data?
        
        ThumbnailCreator.thumbnail(videoURL: videoURL) { (result) in
            switch result
            {
            case .failure(let error):
                shareThatToDebug(string: "[ThumbnailCreator] failed to create thumbnail", error: error)
            case .success(let data):
                renderedThumbnail = data
            }
            dispatchGroup.leave()
        }
        VideoExporter.exportVideo(videoURL: videoURL) { (result) in
            switch result
            {
            case .failure(let error):
                shareThatToDebug(string: "[VideoExporter] failed to create video export", error: error)
            case .success(let data):
                renderedVideo = data
            }
            dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: .main)
        {
            
            guard let renderedVideo = renderedVideo else { return completion(.failure(Error.video)) }
            guard let renderedThumbnail = renderedThumbnail else { return completion(.failure(Error.thumbnail)) }
            completion(.success((renderedThumbnail, renderedVideo)))
        }
    }
}
