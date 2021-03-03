//
//  UGC.swift
//  UCGCreator
//
//  Created by Brian Anglin on 2/9/21.
//

import Foundation
import AVFoundation
import UIKit
import Photos

public protocol VideoContentDelegate {
    func videoDidComplete(url: URL)
}

public protocol VideoConent {
    func videoComplete() -> Bool
    var videoURL: URL? { get }
    var videoSegments: [VideoSegment] { get }
    var delegate: VideoContentDelegate? { get set }
}

public class UGC: VideoConent {
    
    let renderSettings : UGCRenderSettings
    let id: UUID = UUID()
    var scenes: [UGCSecne] = []
    var sceneConfigurations: [UCGSceneConfiguration] = []
    
    var duration : CMTime = CMTime(value: 0, timescale: 1, flags: CMTimeFlags(rawValue: 1), epoch: 0)
    var durationTillNow : CMTime = CMTime(value: 0, timescale: 1, flags: CMTimeFlags(rawValue: 1), epoch: 0)
    
    var mainComposition : AVMutableComposition?
    var outputComposition : AVMutableVideoComposition?
    var instruction : AVMutableVideoCompositionInstruction?
    var ugcExporter : AVAssetExportSession?
    var mainTrack: AVMutableCompositionTrack?
    
    
    public var displayUrl: URL?
    
    let defaultVideoUrl: URL
    
    var ugcDispatchGroup = DispatchGroup()
    let ugcRenderDispatchQueue : DispatchQueue
    
    static var createdUGCs: [UGC] = []
    
    
    public init(defaultVideoUrl: URL, renderSettings: UGCRenderSettings){
        self.defaultVideoUrl = defaultVideoUrl
        self.renderSettings = renderSettings
        self.ugcRenderDispatchQueue = DispatchQueue.init(label: "com.Sharethat.to.ugcRenderDispatchQueue-" + id.uuidString,
                                                               qos: .userInteractive,
                                                               attributes: [.concurrent],
                                                               autoreleaseFrequency: .workItem,
                                                               target: nil)
        UGC.createdUGCs.append(self)
    }
    
    func makeFoundationComponents(){
        mainComposition = AVMutableComposition()
        outputComposition = AVMutableVideoComposition()
        instruction = AVMutableVideoCompositionInstruction()
        
        guard let outputURL = ContentHelper.createFileURL(filename: id.uuidString,
                                                          filenameExt: self.renderSettings.filenameExt) else {
            self.status = .usingDefaultVideo
            self.displayUrl = self.defaultVideoUrl
            Logger.log(message: "Unable to create cache directory and file. ")
            return
        }
        self.displayUrl = outputURL

        guard let mainTrack: AVMutableCompositionTrack = self.mainComposition!.addMutableTrack(
                withMediaType: .video,
                preferredTrackID: Int32(kCMPersistentTrackID_Invalid)
        ) else {
            self.useDefaultVideoUrl(loggerMessage: "Unable to create UGC mainTrack")
            return
        }
        self.mainTrack = mainTrack
    }
    
//    public func createScene() -> UGCSecne {
//        let scene = UGCSecne(ugc: self, orderInUgc: (scenes.count+1) )
//        switch status {
//        case .creating:
//            scenes.append(scene)
//        default:
//            Logger.log(message: "Scene Not Added to UGC.  self.status != .creating")
//        }
//        return scene
//    }
    
    public func createSceneConfiguration() -> UCGSceneConfiguration {
        let sceneConfiguration = UCGSceneConfiguration(renderSettings: self.renderSettings)
        sceneConfigurations.append(sceneConfiguration)
//        switch status {
//        case .creating:
//            scenes.append(scene)
//        default:
//            Logger.log(message: "Scene Not Added to UGC.  self.status != .creating")
//        }
        return sceneConfiguration
    }
    
    public func ugcReady() {
        switch status {
        case .creating, .partial:
            self.startExport()
            status = .locked
        default:
            Logger.log(message: "UGC already rendering. Cannot render again. Did you call this function twice on a single UGC? ")
        }
    }
    
    func cancelExport(seconds: Int){
        if(seconds == 0){
            Logger.log(message: "UGC Export Canceled")
            self.ugcExporter?.cancelExport()
            self.status = .canceled
        } else {
            let dispatchTime = DispatchTime.now() + .seconds(seconds)
            DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: dispatchTime) {
                if(self.ugcExporter?.status != .completed){
                    self.ugcExporter?.cancelExport()
                }
                self.status = .canceled
            }
        }
    }
    
    func startExport(){
        self.status = .exporting
        ugcDispatchGroup.notify(queue: ugcRenderDispatchQueue ) {
            self.makeFoundationComponents()
            
            
            
            for scene in self.scenes {
                if scene.status == .completed {
                    
                    
                    
                    guard let assetURL = scene.videoURL else {
                        Logger.log(message: "Unable to add scene \(scene.id). URL not valid.")
                        continue
                    }
                    
                    let sceneVideoAsset = AVAsset(url: assetURL)
                    
                    guard let sceneVideoTrack = sceneVideoAsset.tracks(withMediaType: .video).first
                    else {
                        Logger.log(message: "Unable to add scene \(scene.id) to the UGC. Scene has no video Track.")
                        continue
                    }
                    
                    self.duration = CMTimeAdd(self.duration, sceneVideoAsset.duration)
                    
                    do{
                        try self.mainTrack!.insertTimeRange(
                            CMTimeRangeMake(start: .zero, duration: sceneVideoAsset.duration),
                            of: sceneVideoTrack,
                            at: .zero)
                    } catch {
                        // renders UGC without Scene
                        Logger.log(message: "Unable to add scene \(scene.id) to the UGC. Trouble insertTimeRange to mainTrack.")
                        continue
                    }
                    
                    let sceneInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: sceneVideoTrack)
                    self.durationTillNow = CMTimeAdd(self.durationTillNow, sceneVideoAsset.duration)
                    
                    if scene.id != self.scenes.last?.id {
                        sceneInstruction.setOpacity(0.0, at: self.durationTillNow)
                    }
                    self.instruction!.layerInstructions.append(sceneInstruction)
                } else {
                    Logger.log(message: "Scene not completed")
                }
            }
            
            self.instruction!.timeRange = CMTimeRangeMake(
                start: .zero,
                duration: self.durationTillNow
            )
            
            self.outputComposition!.instructions = [self.instruction!]
            self.outputComposition!.frameDuration = CMTimeMake(value: 1, timescale: 30)
            self.outputComposition!.renderSize = self.renderSettings.size
            
            guard let exporter = AVAssetExportSession(
                    asset: self.mainComposition!,
                    presetName: AVAssetExportPresetHighestQuality )
            else {
                self.useDefaultVideoUrl(loggerMessage: "UGC Exporter Not Created")
                return
            }
            self.ugcExporter = exporter
            exporter.outputURL = self.displayUrl
            exporter.outputFileType = self.renderSettings.outputFileType
            exporter.shouldOptimizeForNetworkUse = true
            exporter.videoComposition = self.outputComposition
            
            self.cancelExport(seconds: 120)
            
            Logger.log(message: "UGC Generated")
            exporter.exportAsynchronously {
                Logger.log(message: "UGC Rendered ")
                switch exporter.status {
                    case .completed:
                        self.status = .completed
                        guard let delegate = self.delegate else {
                            Logger.log(message: "UGC Delegate not set.")
                            return
                        }
                        DispatchQueue.main.async {
                            delegate.videoDidComplete(url: self.displayUrl!)
                        }
                    default:
                        // TODO: UGC render fails, but scenes succeed
//                        self.status = .canceled
                        self.startExport()
                        Logger.log(message: "UGC Exporter failed with status of \(exporter.status.rawValue). See AVAssetExportSession.Status Docs to debug")
                        guard let delegate = self.delegate else {
                            Logger.log(message: "UGC Delegate not set.")
                            return
                        }
                        self.status = .usingDefaultVideo
                        delegate.videoDidComplete(url: self.defaultVideoUrl)
                }
            }
        }
    }
    
    private func useDefaultVideoUrl(loggerMessage: String) {
        self.status = .usingDefaultVideo
        self.displayUrl = self.defaultVideoUrl
        Logger.log(message: loggerMessage)
    }
    
    enum Status : Int {
        case failed = 1
        case completed = 2
        case creating = 3
        case exporting = 4
        case canceled = 5
        case locked = 6
        case partial = 7
        case usingDefaultVideo = 8
    }
    
    public var videoSegments: [VideoSegment] {
        get { self.scenes }
    }
    
    var status: Status = .creating
    public var delegate: VideoContentDelegate?
    
    public func videoComplete() -> Bool {
        guard let progress = self.ugcExporter?.progress else {
            return false
        }
        return progress == 1
    }
    
    public var videoURL: URL? {
        get { self.displayUrl }
    }
}


