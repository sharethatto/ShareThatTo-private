//
//  UGCScene.swift
//  UCGCreator
//
//  Created by Brian Anglin on 2/12/21.
//

import Foundation
import AVFoundation
import UIKit
import Photos

public protocol VideoSegmentDelegate {
    func videSegmentDidComplete(url: URL)
}

public protocol VideoSegment {
    func videoComplete() -> Bool
    var delegate: VideoSegmentDelegate? { get set }
    var videoURL: URL? { get }
}

public class UGCSecne : VideoSegment {
    
    public var delegate:VideoSegmentDelegate?
    
    let id :UUID = UUID()
    let orderInUgc : Int
    var sceneDuration : CMTime?
    var sceneExporter : AVAssetExportSession?
    
    var sceneTrack: AVMutableCompositionTrack?
    var sceneComposition = AVMutableComposition()
    var sceneOutputComposition = AVMutableVideoComposition()
    var sceneOutputInstruction = AVMutableVideoCompositionInstruction()
    var layerInstruction = AVVideoCompositionLayerInstruction()
    let outputLayer = CALayer()
    
    var status: Status = .creating
    
    let renderSettings: UGCRenderSettings
    let ugc: UGC
    
    let sceneDispatchGroup = DispatchGroup()
    
    public let displayUrl: URL?
    
    public init(ugc: UGC, orderInUgc: Int){
        self.orderInUgc = orderInUgc
        self.ugc = ugc
        self.sceneDuration = nil
        self.sceneExporter = nil
        renderSettings = ugc.renderSettings
        
        outputLayer.frame = CGRect(x: 0, y: 0, width: renderSettings.assetWidth, height: renderSettings.assetHeight)
        
        
        
        guard let outputURL = ContentHelper.createFileURL(filename: self.id.uuidString,
                                                          filenameExt: self.renderSettings.filenameExt) else {
            status = .failed
            Logger.log(message: "Cannot create output URL")
            self.sceneTrack = nil
            self.displayUrl = nil
            return
        }
        self.displayUrl = outputURL
        
        guard let sceneTrack = sceneComposition.addMutableTrack(
                withMediaType: .video,
                preferredTrackID: Int32(kCMPersistentTrackID_Invalid)
        ) else {
            Logger.log(message: "Failed to create main scene track.")
            status = .failed
            self.sceneTrack = nil
            return
        }
        self.sceneTrack = sceneTrack
    }
    
    func remakeScene(){
        sceneComposition = AVMutableComposition()
        sceneOutputComposition = AVMutableVideoComposition()
        sceneOutputInstruction = AVMutableVideoCompositionInstruction()
        layerInstruction = AVVideoCompositionLayerInstruction()
        self.outputLayer.sublayers?.removeAll()
        guard let sceneTrack = sceneComposition.addMutableTrack(
                withMediaType: .video,
                preferredTrackID: Int32(kCMPersistentTrackID_Invalid)
        ) else {
            Logger.log(message: "Failed to create main scene track.")
            status = .failed
            self.sceneTrack = nil
            return
        }
        self.sceneTrack = sceneTrack
    }
    
    public func withImageLayer(format: UGCImageFormat, url: URL) -> UGCSecne {
        switch status {
        case .creating :
            self.sceneDispatchGroup.enter()
            let workerItem =  DispatchWorkItem.init(block: {
                let imageLayer = UGCImageLayer()
                
                guard let bgImage = UIImage(contentsOfFile: url.path) else {
                    self.status = .failed
                    Logger.log(message: "Unable to load image or Layer into scene.  Failing scene.  Is the path correct?")
                    return
                }
                
                if(self.status != .failed) {
                    format.attributes.append(.contents( bgImage.cgImage as Any ))
                    imageLayer.applyAttributes(layerAttributes: format.attributes)
                    if (imageLayer.defaultPlacements == true){
                        imageLayer.transformToExpectedLayerPlacement(
                            outputLayerSize: self.outputLayer.frame.size
                        )
                    }
                    imageLayer.borderWidth = 4
                    imageLayer.borderColor = UIColor.red.cgColor
                    self.outputLayer.addSublayer(imageLayer)
                }
                self.sceneDispatchGroup.leave()
            } )
            let didAppendToQueue = UGCQueueManager.appendSceneCreationComponentToQueue(workerItem: workerItem)
            if (!didAppendToQueue){
                Logger.log(message: "didn't add to UGCQueueManager")
                self.status = .failed
            }
        default :
            Logger.log(message: "Scene failed with status of \(self.status). See UGCSecne.Status Docs to debug")
        }
        return self
    }
    
    public func withVideoLayer(format: UGCVideoFormat, url: URL) -> UGCSecne {
        switch status {
        case .creating :
            self.sceneDispatchGroup.enter()
            let workerItem = DispatchWorkItem.init(block: {
                
                let videoLayer = UGCVideoLayer()
                let videoAsset = AVAsset(url: url)
                guard let sceneTrack = self.sceneTrack else {
                    self.status = .failed
                    Logger.log(message: "Unable to get video track from AVAsset.")
                    return
                }
                
                guard let videoTrack = videoAsset.tracks(withMediaType: .video).first else {
                    self.status = .failed
                    Logger.log(message: "Unable to get video track from AVAsset.")
                    return
                }
                
                let videoInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: sceneTrack)
                
                videoLayer.applyAttributes(layerAttributes: format.attributes)
                
                if (videoLayer.defaultPlacements == true){
                    videoLayer.transformToExpectedLayerPlacement(
                        outputLayerSize: self.outputLayer.frame.size,
                        assetSize: videoTrack.naturalSize
                    )
                }
                
                let scaleFactor = UGCVideoLayer.transformToExpectedAssetScale(
                    outputLayerSize: self.outputLayer.frame.size,
                    outputFrameSize: videoLayer.frame.size,
                    assetSize: videoTrack.naturalSize
                )
                
                videoInstruction.setTransform(scaleFactor, at: .zero)

                do {
                    try sceneTrack.insertTimeRange(
                        CMTimeRangeMake(start: .zero, duration: videoAsset.duration),
                        of: videoTrack,
                        at: .zero)
                } catch {
                    self.status = .failed
                    Logger.log(message: "Cannot insertTimeRange into scene Track.")
                    return
                }

                self.ugc.duration = CMTimeAdd(self.ugc.duration, videoAsset.duration)
                self.sceneDuration = videoAsset.duration

                self.sceneOutputComposition.animationTool = AVVideoCompositionCoreAnimationTool(
                    postProcessingAsVideoLayer: videoLayer,
                    in: self.outputLayer)
                
                self.sceneOutputInstruction.layerInstructions.append(videoInstruction)
                self.outputLayer.addSublayer(videoLayer)
                self.sceneDispatchGroup.leave()
            } )
            let didAppendToQueue = UGCQueueManager.appendSceneCreationComponentToQueue(workerItem: workerItem)
            if (!didAppendToQueue){
                Logger.log(message: "didn't add to UGCQueueManager")
                self.status = .failed
            }
        default :
            Logger.log(message: "Scene failed with status of \(self.status). See UGCSecne.Status Docs to debug")
        }
        return self
    }
    
    public func withTextLayer(format: UGCTextFormat, parameters: [String:String]) -> UGCSecne {
        switch status {
        case .creating :
            self.sceneDispatchGroup.enter()
            let workerItem = DispatchWorkItem.init(block: {
                
                var outputText = format.textTemplate
                for (name, value) in parameters {
                    outputText = outputText.replacingOccurrences(of: "{{\(name)}}", with: value)
                }
                
                let textLayer = UGCTextLayer()
                format.appendAttribute(.string(outputText))
                textLayer.applyAttributes(layerAttributes: format.attributes)
                
                textLayer.borderWidth = 4
                textLayer.borderColor = UIColor.red.cgColor
                
                textLayer.backgroundColor = UIColor.green.cgColor
                
                if (textLayer.defaultPlacements == true){
                    textLayer.transformToExpectedLayerPlacement(
                        outputLayerSize: self.outputLayer.frame.size
                    )
                }
                
                self.outputLayer.addSublayer(textLayer)
                textLayer.displayIfNeeded()
                self.sceneDispatchGroup.leave()
            } )
            let didAppendToQueue = UGCQueueManager.appendSceneCreationComponentToQueue(workerItem: workerItem)
            if (!didAppendToQueue){
                Logger.log(message: "didn't add to UGCQueueManager")
                self.status = .failed
            }
        default :
            Logger.log(message: "Scene failed with status of \(self.status). See UGCSecne.Status Docs to debug")
        }
        return self
    }
    
    public func sceneReady() {
        switch status {
        case .creating :
            self.sceneDispatchGroup.enter()
            let workerItem = DispatchWorkItem {
                
                
                guard let sceneDuration = self.sceneDuration else {
                    self.status = .failed
                    Logger.log(message: "Duration Never Set. Is there a Video in this scene?")
                    return
                }
                self.sceneOutputInstruction.timeRange = CMTimeRangeMake(
                    start: .zero,
                    duration: sceneDuration
                )
                
                self.sceneOutputComposition.instructions = [self.sceneOutputInstruction]
                self.sceneOutputComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
                self.sceneOutputComposition.renderSize = self.renderSettings.size
                
                // TODO: Implement Crop
//                exporter.timeRange = CMTimeRange(
//                    start: CMTime(seconds: Double(60 ), preferredTimescale: 1000),
//                    duration: CMTime(seconds: Double(5 ), preferredTimescale: 1000))
                self.sceneDispatchGroup.leave()
            }
            let didAppendToQueue = UGCQueueManager.appendSceneCreationComponentToQueue(workerItem: workerItem)
            if (!didAppendToQueue){
                Logger.log(message: "didn't add to UGCQueueManager")
                self.status = .failed
            }
            
            self.startExport()
            
        default:
            Logger.log(message: "Scene failed with status of \(self.status). See UGCSecne.Status Docs to debug")
        }
    }
    
    func cancelExport(seconds: Int){
        if(seconds == 0){
            Logger.log(message: "Scene Export Canceled")
            self.sceneExporter?.cancelExport()
            self.status = .canceled
        } else {
            let dispatchTime = DispatchTime.now() + .seconds(seconds)
            DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: dispatchTime) {
                if(self.sceneExporter?.status != .completed){
                    self.sceneExporter?.cancelExport()
                }
                self.status = .canceled
            }
        }
    }
    
    func startExport() {
        print("started Export")
        self.sceneDispatchGroup.notify(queue: DispatchQueue.global(qos: .userInteractive)) {
            print("finished called dispatch group")
            self.status = .exporting
            
            guard let exporter = AVAssetExportSession(
                asset: self.sceneComposition,
              presetName: AVAssetExportPresetHighestQuality
            ) else {
                self.status = .failed
                Logger.log(message: "Exporter unable to be created")
                return
            }
            self.sceneExporter = exporter
            
            guard let outputURL = self.displayUrl else {
                self.status = .failed
                Logger.log(message: "No Cache file URL set.")
                return
            }
            
            self.sceneExporter?.outputURL = ContentHelper.createFileURL(filename: self.id.uuidString,
                                                                        filenameExt: self.renderSettings.filenameExt)!
            self.sceneExporter?.outputFileType = self.renderSettings.outputFileType
            self.sceneExporter?.shouldOptimizeForNetworkUse = true
            self.sceneExporter?.videoComposition = self.sceneOutputComposition
            
            Logger.log(message: "Scene Generated")
            self.cancelExport(seconds: 120)
            print(self.outputLayer.sublayers)
            self.sceneExporter?.exportAsynchronously {
                Logger.log(message: "Scene Rendered")
//                self.ugc.ugcDispatchGroup.leave()
                
                switch self.sceneExporter?.status {
                    case .completed:
                        self.status = .completed
                        guard let delegate = self.delegate else {
                            return
                        }
                        DispatchQueue.main.async {
                            delegate.videSegmentDidComplete( url: self.videoURL! )
                        }
                    default:
                        Logger.log(message: "Exporter failed with status of \(String(describing: self.sceneExporter?.status.rawValue)). See AVAssetExportSession.Status Docs to debug")
                        self.status = .failed
                        return
                }
            }
        }
    }
    
    public func useDefaultVideoUrl(loggerMessage: String) {
        self.status = .failed
        Logger.log(message: loggerMessage)
    }
    
    public var videoURL: URL? {
        get {
            switch status{
            case .completed:
                return self.displayUrl
            default:
                Logger.log(message: "Scene failed with status of \(self.status). See UGCSecne.Status Docs to debug")
                return nil
            }
        }
    }
    
    public func videoComplete() -> Bool
    {
        guard let progress = self.sceneExporter?.progress else {
            return false
        }
        return progress == 1
    }
    
    enum Status : Int {
        case locked = 0
        case failed = 1
        case completed = 2
        case creating = 3
        case exporting = 4
        case canceled = 5
    }
    
}


/*


 Origin Flipped
 https://stackoverflow.com/questions/5176737/calayer-frame-origin-y-is-flipped-0-is-at-the-bottom
 
 
 */
