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

public class UCGSceneConfiguration
{
    private var configurations: [UGCLayerConfiguration] = []
    private let renderSettings: UGCRenderSettings
    public init(renderSettings: UGCRenderSettings) //ugc: UGC, orderInUgc: Int)
    {
        self.renderSettings = renderSettings
    }
    
    public func withImageLayer(format: UGCImageFormat, url: URL) -> UCGSceneConfiguration {
        configurations.append(UGCImageLayerConfiguration(format: format, url: url))
        return self
    }

    public func withVideoLayer(format: UGCVideoFormat, url: URL) -> UCGSceneConfiguration {
        configurations.append(UGCVideoLayerConfiguration(format: format, url: url))
        return self
    }
    
    public func withTextLayer(format: UGCTextFormat, parameters: [String:String]) -> UCGSceneConfiguration {
        configurations.append(UGCTextLayerConfiguration(format: format, parameters: parameters))
        return self
    }
    
    
    
    public func createScene() -> UGCSecne?
    {
        let optionalScene = try? UGCSecne(configurations:configurations, renderSettings: renderSettings)
        guard let scene = optionalScene else {
            return nil
        }
        scene.sceneReady()
        return scene
    }
    
}

enum UGCSceneConfigurationError: Error {
    case unknown
}

public class UGCSecne : VideoSegment {
    
    public var delegate:VideoSegmentDelegate?
    
    let id :UUID = UUID()
//    let orderInUgc : Int
    var sceneDuration : CMTime?
    
    var sceneExporter : AVAssetExportSession?
    
    var sceneTrack: AVMutableCompositionTrack
    var sceneComposition : AVMutableComposition
    var sceneOutputComposition : AVMutableVideoComposition
    var sceneOutputInstruction : AVMutableVideoCompositionInstruction
    var layerInstruction : AVVideoCompositionLayerInstruction
    var outputLayer : CALayer
    
    var status: Status = .creating
    
//    let ugc: UGC
    
    let sceneDispatchGroup = DispatchGroup()
    var sceneCreationBlocks: [DispatchWorkItem] = []
    var setAttributesDispatchQueue : DispatchQueue?
    var queueLabel : String?
    static let sceneExporterDispatchQueue = DispatchQueue.init(label: "com.ShareThat.To.SceneExporterDispatchQueue",
                                                                  qos: .userInteractive,
                                                                  attributes: [.concurrent],
                                                                  autoreleaseFrequency: .workItem,
                                                                  target: nil)
    
    
    public let displayUrl: URL
    public let renderSettings: UGCRenderSettings
    private let configurations: [UGCLayerConfiguration]
    internal init(configurations: [UGCLayerConfiguration], renderSettings: UGCRenderSettings) throws {
        self.configurations = configurations
        self.renderSettings = renderSettings

        
        guard let outputURL = ContentHelper.createFileURL(filename: self.id.uuidString,
                                                          filenameExt: renderSettings.filenameExt) else {
            status = .failed
            Logger.log(message: "Cannot create output URL")
            throw UGCSceneConfigurationError.unknown
        }
        
        self.displayUrl = outputURL

        self.sceneComposition = AVMutableComposition()
        self.sceneOutputComposition = AVMutableVideoComposition()
        self.sceneOutputInstruction = AVMutableVideoCompositionInstruction()
        self.layerInstruction = AVVideoCompositionLayerInstruction()
        self.outputLayer = CALayer()
        
        outputLayer.frame = CGRect(x: 0, y: 0, width: renderSettings.assetWidth, height: renderSettings.assetHeight)
        
        let optionalSceneTrack = sceneComposition.addMutableTrack(
            withMediaType: .video,
            preferredTrackID: Int32(kCMPersistentTrackID_Invalid)
        )
        guard let sceneTrack = optionalSceneTrack else {
            throw UGCSceneConfigurationError.unknown
        
        }
        self.sceneTrack = sceneTrack
        
//        else {
//            Logger.log(message: "Failed to create main scene track.")
//            status = .failed
////            self.sceneTrack = nil
//            return
//        }
//        self.sceneTrack = sceneTrack
        
        queueLabel = "com.Sharethat.to.setAttributesDispatchQueue-" + self.id.uuidString
        
        setAttributesDispatchQueue = DispatchQueue.init(label: queueLabel!,
                                                          qos: .userInteractive,
                                                          attributes: [],
                                                          autoreleaseFrequency: .workItem,
                                                          target: nil)
    }
    
    public func sceneReady() {
//        makeFoundationComponents()
        for configuration in configurations {
            configuration.build(scene: self)
        }
    
                let durationLogger = DurationLogger.begin(prefix: "[UGCScene] sceneReady")
                
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
//                self.sceneDispatchGroup.leave()
//                durationLogger.finish()
//            }
//            sceneCreationBlocks.append(workerItem)
            
        self.startExport()
    }
    
    func cancelExport(seconds: Int){
        
        // TODO: [Brian 3/2] Figure out cancels
//        if(seconds == 0){
//            Logger.log(message: "Scene Export Canceled")
//            self.sceneExporter?.cancelExport()
//            self.status = .canceled
//        } else {
//            let dispatchTime = DispatchTime.now() + .seconds(seconds)
//            DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: dispatchTime) {
//                if(self.sceneExporter?.status != .completed){
//                    self.sceneExporter?.cancelExport()
//                }
//                self.status = .canceled
//            }
//        }
    }
    
    func startExport() {
//        if(sceneCreationBlocks.count > 0 ) {
            status = .exporting
            
            sceneDispatchGroup.notify(queue: UGCSecne.sceneExporterDispatchQueue) {
                guard let exporter = AVAssetExportSession(
                    asset: self.sceneComposition,
                  presetName: AVAssetExportPresetHighestQuality
                ) else {
                    self.status = .failed
                    Logger.log(message: "Exporter unable to be created")
                    return
                }
                self.sceneExporter = exporter
                
                print(self.sceneExporter)
                print(self.sceneOutputComposition)
                
                guard self.displayUrl != nil else {
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
                
                // TODO: [BRIAN 3/2] Figure out how to handle async
//                self.ugc.ugcDispatchGroup.enter()
                self.sceneExporter?.exportAsynchronously {
                    Logger.log(message: "Scene Rendered")
                    
                    // TODO: [BRIAN 3/2] Figure out how to handle async
//                    self.ugc.ugcDispatchGroup.leave()
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
                            Logger.log(message: "Exporter failed with status of \( self.sceneExporter?.status.rawValue). See AVAssetExportSession.Status Docs to debug")
                            self.status = .failed
                            return
                    }
                }
            }

            
//        }
        
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
        
        // TODO: [Brian 3/2] Renable this?
//        guard let progress = self.sceneExporter.progress else {
//            return false
//        }
//        return progress == 1
        return false
    }
    
    enum Status : Int {
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
