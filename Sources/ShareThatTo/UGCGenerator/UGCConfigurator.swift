//
//  BaseVideoSettings.swift
//  video_generator
//
//  Created by Brian Anglin on 2/8/21.
//
import UIKit
import Foundation
import AVFoundation

//H.264 codec
//AAC audio
//3500 kbps bitrate
//Frame rate of 30 fps (frames per second)
//Video can be a maximum of 60 seconds
//Maximum video width is 1080 px (pixels) wide
//Videos should be 920 pixels tall

//public struct UGCConfigurator {
//
//    public static func createShareThatToCachesDirectory(){
//        let fileManager = FileManager.default
//        if let cachesDirectoryUrl = try? fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true) {
//            let shareThatToDirectory = cachesDirectoryUrl.appendingPathComponent("ShareThatTo")
//            if !fileManager.fileExists(atPath: shareThatToDirectory.absoluteString) {
//                do {
//                    try fileManager.createDirectory(atPath: shareThatToDirectory.absoluteString, withIntermediateDirectories: true, attributes: nil)
//                } catch {
//                    Logger.log("Cannot create Share That To Folder in caches directory. \(error.localizedDescription)")
//                }
//            } else {
//                Logger.log("Share That To Folder in caches directory exists.")
//            }
//        } else {
//            Logger.log("Cannot get cachesDirectoryUrl")
//        }
//    }
//
//    public static func removeShareThatToFilesInCachesDirectory(){
//        let fileManager = FileManager.default
//        if let documentsUrl = try? fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true) {
//            let documentsPath = documentsUrl.path
//            print(try! fileManager.contentsOfDirectory(atPath: "\(documentsPath)"))
//            let fileNames = try! fileManager.contentsOfDirectory(atPath: "\(documentsPath)")
//            for fileName in fileNames {
//                let filePathName = "\(documentsPath)/\(fileName)"
//                try! fileManager.removeItem(atPath: filePathName)
//            }
//            print(try! fileManager.contentsOfDirectory(atPath: "\(documentsPath)"))
//        } else {
//            Logger.log("Cannot get cachesDirectoryUrl")
//        }
//    }
//
//
//    public static func removeShareThatToDirectory(){
//        let fileManager = FileManager.default
//        if let cachesDirectoryUrl = try? fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true) {
//            let shareThatToDirectory = cachesDirectoryUrl.appendingPathComponent("ShareThatTo")
//
//            do {
//                let fileNames = try fileManager.removeItem(atPath: shareThatToDirectory.path)
//            } catch {
//                Logger.log("Cannot remove Share That To Folder in caches directory. \(error.localizedDescription)")
//            }
//        } else {
//            Logger.log("Cannot get cachesDirectoryUrl")
//        }
//    }
//
//    public struct RenderSettings {
//
//        var size: CGSize
//        var fps: Int32
//        var avCodecKey: AVVideoCodecType
//        var filename: String
//        var filenameExt: String
//        var assetHeight: Double
//        var assetWidth: Double
//        var outputURL: URL?
//        var outputFileType: AVFileType
//
//        public init(shareOutletType: ShareOutletType, sceneId: String){
//            switch shareOutletType {
//                case .igStoryOptimized:
//                    assetHeight = 920
//                    assetWidth = 517.5
//                    size = CGSize(width: assetWidth, height: assetHeight)
//                    fps = 30
//                    if #available(iOS 11.0, *) {
//                        avCodecKey = AVVideoCodecType.h264
//                    } else {
//                        avCodecKey = AVVideoCodecType(rawValue: AVVideoCodecH264)
//                    }
//                    filename = UUID().uuidString
//                    filenameExt = "mp4"
//                    outputURL = RenderSettings.getTemporaryFileURL(filename: filename, filenameExt: filenameExt)
//                    outputFileType = AVFileType.mov
//            }
//        }
//
//        private static func getTemporaryFileURL(filename: String, filenameExt: String) -> URL? {
//            // Use the CachesDirectory so the rendered video file sticks around as long as we need it to.
//            // Using the CachesDirectory ensures the file won't be included in a backup of the app.
//            let fileManager = FileManager.default
//            if let tmpDirURL = try? fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true) {
//                return tmpDirURL.appendingPathComponent(filename).appendingPathExtension(filenameExt)
//            }
//            Logger.log(message: "Unable to create file in temporary directoy")
//            return nil
//        }
//
//        public enum ShareOutletType {
//            case .igStoryOptimized
//        }
//    }
//
//}


public struct UGCRenderSettings {
    
    var size: CGSize
    var fps: Int32
    var avCodecKey: AVVideoCodecType
    var filenameExt: String
    var assetHeight: Double
    var assetWidth: Double
    var outputFileType: AVFileType
    
    public init(shareOutletType: ShareOutletType){
        switch shareOutletType {
            case .defaultVideoAsset:
                assetHeight = 920
                assetWidth = 517.5
                size = CGSize(width: assetWidth, height: assetHeight)
                fps = 30
                if #available(iOS 11.0, *) {
                    avCodecKey = AVVideoCodecType.h264
                } else {
                    avCodecKey = AVVideoCodecType(rawValue: AVVideoCodecH264)
                }
                filenameExt = "mp4"
                outputFileType = AVFileType.mp4
        }
    }
//
//    private static func getTemporaryFileURL(filename: String, filenameExt: String) -> URL? {
//        // Use the CachesDirectory so the rendered video file sticks around as long as we need it to.
//        // Using the CachesDirectory ensures the file won't be included in a backup of the app.
//        let fileManager = FileManager.default
//        if let tmpDirURL = try? fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true) {
//            return tmpDirURL.appendingPathComponent(filename).appendingPathExtension(filenameExt)
//        }
//        Logger.log(message: "Unable to create file in temporary directoy")
//        return nil
//    }
    
    public enum ShareOutletType {
        case defaultVideoAsset
    }
}

