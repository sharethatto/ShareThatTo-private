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
    
    var duration : CMTime = CMTime(value: 0, timescale: 1, flags: CMTimeFlags(rawValue: 1), epoch: 0)
    var durationTillNow : CMTime = CMTime(value: 0, timescale: 1, flags: CMTimeFlags(rawValue: 1), epoch: 0)
    
    let mainComposition = AVMutableComposition()
    let outputComposition = AVMutableVideoComposition()
    let instruction = AVMutableVideoCompositionInstruction()
    var ugcExporter: AVAssetExportSession?
    
    var displayUrl: URL
    
    let defaultVideoUrl: URL
    
    let ugcDispatchGroup = DispatchGroup()
    let sceneRenderDispatchQueue : DispatchQueue
    
    
    public init(defaultVideoUrl: URL, renderSettings: UGCRenderSettings){
        
        self.defaultVideoUrl = defaultVideoUrl
        self.renderSettings = renderSettings
        self.sceneRenderDispatchQueue = DispatchQueue.init(label: "com.Sharethat.to.sceneRenderDispatchQueue." + id.uuidString,
                                                               qos: .userInteractive,
                                                               attributes: [.concurrent],
                                                               autoreleaseFrequency: .workItem,
                                                               target: nil)
        guard let outputURL = ContentHelper.createFileURL(filename: id.uuidString,
                                                          filenameExt: self.renderSettings.filenameExt) else {
            self.status = .usingDefaultVideo
            self.displayUrl = self.defaultVideoUrl
            Logger.log(message: "Unable to create cache directory and file. ")
            return
        }
        self.displayUrl = outputURL
        UGCQueueManager.createdUGCs.append(self)
    }
    
    public func createScene() -> UGCSecne {
        let scene = UGCSecne(ugc: self, orderInUgc: (scenes.count+1) )
        switch status {
        case .creating:
//            ugcDispatchGroup.enter()
            scenes.append(scene)
        default:
            Logger.log(message: "Scene Not Added to UGC.  self.status != .creating")
        }
        return scene
    }
    
    func ugcReady() {
        switch status {
        case .creating, .partial:
            ugcDispatchGroup.notify(queue: sceneRenderDispatchQueue ) {
                
                guard let mainTrack: AVMutableCompositionTrack = self.mainComposition.addMutableTrack(
                        withMediaType: .video,
                        preferredTrackID: Int32(kCMPersistentTrackID_Invalid)
                ) else {
                    self.useDefaultVideoUrl(loggerMessage: "Unable to create UGC mainTrack")
                    return
                }
                
                for scene in self.scenes {
                    
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
                    
                    do{
                        try mainTrack.insertTimeRange(
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
                    self.instruction.layerInstructions.append(sceneInstruction)
                }
                
                self.instruction.timeRange = CMTimeRangeMake(
                    start: .zero,
                    duration: self.durationTillNow
                )
                
                self.outputComposition.instructions = [self.instruction]
                self.outputComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
                self.outputComposition.renderSize = self.renderSettings.size
                
                guard let exporter = AVAssetExportSession(
                        asset: self.mainComposition,
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
                
                let dispatchTime = DispatchTime.now() + 60
                DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: dispatchTime) {
                    if(self.ugcExporter?.status != .completed){
                        self.ugcExporter?.cancelExport()
                        self.useDefaultVideoUrl(loggerMessage: "UGC Exporter timedout with status of \(exporter.status.rawValue). See AVAssetExportSession.Status Docs to debug")
                    }
                }
                
                self.status = .exporting
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
                                delegate.videoDidComplete(url: self.displayUrl)
                            }
                        default:
                            // TODO: UGC render fails, but scenes succeed
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
            status = .locked
        default:
            Logger.log(message: "UGC already rendering. Cannot render again. Did you call this function twice on a single UGC? ")
        }
    }
    
    private func useDefaultVideoUrl(loggerMessage: String) {
        self.status = .usingDefaultVideo
        self.displayUrl = self.defaultVideoUrl
        Logger.log(message: loggerMessage)
    }
    
    enum Status {
        case locked
        case partial
        case usingDefaultVideo
        case completed
        case creating
        case exporting
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


