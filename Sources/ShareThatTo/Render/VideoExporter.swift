//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/7/21.
//

import AVKit
import Foundation

protocol VideoExportProtocol
{
    static func exportVideo(videoURL: URL, completion: @escaping (Result<Data, Swift.Error>) -> Void)
}

extension VideoExporter
{
    enum Error: LocalizedError
    {
        case unknown
        case readFile
        
        var errorDescription: String? {
            switch self
            {
            case .unknown: return NSLocalizedString("An unknown error occurred.", comment: "")
            case .readFile: return NSLocalizedString("Unable to read file.", comment: "")
            }
        }
    }
}

class VideoExporter
{
    // Decide if we want to try and compress the video or not
    // TODO: Check if the video is an mp4 going in
    internal static func exportVideo(videoURL: URL, completion: @escaping (Result<Data, Swift.Error>) -> Void)
    {
        let attribute: [FileAttributeKey : Any]
        let exporter: VideoExportProtocol.Type
        do {
            attribute = try FileManager.default.attributesOfItem(atPath: videoURL.path)
        } catch {
            completion(.failure(Error.readFile))
            return
        }
        
        let size = attribute[FileAttributeKey.size] as? NSNumber ?? -1
        
        // If we can't find the size, assume we need to re-render
        if (size.intValue < 1_000_000 && size != -1)
        {
            exporter = PassThrough.self
        }
        else
        {
            exporter = AVExport.self
        }
        exporter.exportVideo(videoURL: videoURL, completion: completion)
    }

}


class VideoExportErrors
{
    enum Error: LocalizedError
    {
        case unknown
        case readFile
        
        var errorDescription: String? {
            switch self
            {
            case .unknown: return NSLocalizedString("An unknown error occurred.", comment: "")
            case .readFile: return NSLocalizedString("Unable to read file.", comment: "")
            }
        }
    }
}

private class AVExport: VideoExportErrors, VideoExportProtocol
{
    internal static func exportVideo(videoURL: URL, completion: @escaping (Result<Data, Swift.Error>) -> Void)
    {
        guard let avexs =  AVAssetExportSession(asset: AVAsset(url: videoURL), presetName: AVAssetExportPresetMediumQuality) else { return completion(.failure(Error.readFile))}
        guard let directory = TemporaryDirectoryHelper.createTempDirectory(directoryName: nil) else { return completion(.failure(Error.readFile)) }
        let filepath = directory.appendingPathComponent("export.mp4")
        
        avexs.outputURL = filepath
        avexs.outputFileType = .mp4
        avexs.exportAsynchronously {
            do {
                let videoContent =  try Data.init(contentsOf: filepath)
                completion(.success(videoContent))
            } catch let error
            {
                completion(.failure(error))
            }
        }
    }
}

private class PassThrough: VideoExportErrors, VideoExportProtocol
{
    internal static func exportVideo(videoURL: URL, completion: @escaping (Result<Data, Swift.Error>) -> Void)
    {
        do {
            let videoContent =  try Data.init(contentsOf: videoURL)
            completion(.success(videoContent))
        } catch let error
        {
            completion(.failure(error))
        }
    }
}
