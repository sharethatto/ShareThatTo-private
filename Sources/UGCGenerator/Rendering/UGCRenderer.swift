//
//  File.swift
//  
//
//  Created by Brian Anglin on 3/3/21.
//
import Foundation
import AVFoundation
import ShareThatToCore
import UIKit

internal class UGCRenderer
{
    
    var durationTillNow : CMTime = CMTime(value: 0, timescale: 1, flags: CMTimeFlags(rawValue: 1), epoch: 0)
    
    var mainComposition : AVMutableComposition
    var outputComposition : AVMutableVideoComposition
    var instruction : AVMutableVideoCompositionInstruction
    var mainTrack: AVMutableCompositionTrack
    
    var ugcExporter : AVAssetExportSession?
    
    internal var displayURL: URL

    let renderSettings : UGCRenderSettings
    let scenes: [UGCSuccessResult]
    public init(scenes: [UGCSuccessResult],  renderSettings: UGCRenderSettings)  throws
    {
        self.scenes = scenes
        self.renderSettings = renderSettings
       

        mainComposition = AVMutableComposition()
        outputComposition = AVMutableVideoComposition()
        instruction = AVMutableVideoCompositionInstruction()
        
        guard let outputURL = ContentHelper.createFileURL(filename: UUID().uuidString,
                                                          filenameExt: self.renderSettings.filenameExt) else {
            throw UGCError.unknown
        }
        self.displayURL = outputURL

        guard let mainTrack: AVMutableCompositionTrack = self.mainComposition.addMutableTrack(
                withMediaType: .video,
                preferredTrackID: Int32(kCMPersistentTrackID_Invalid)
        ) else {
            throw UGCError.unknown
        }
        self.mainTrack = mainTrack
    }
        
    func startExport(completion: @escaping UGCResultCompletion)
    {
        let durationLogger = UGCDurationLogger.begin(prefix: "[UGC startExport]")
        for scene in self.scenes.reversed() {
            let sceneVideoAsset = AVAsset(url: scene.displayURL)
                    
            guard let sceneVideoTrack = sceneVideoAsset.tracks(withMediaType: .video).first
            else {
                UGCLogger.log(message: "Unable to add scene \(scene) to the UGC. Scene has no video Track.")
                continue
            }

            do {
                try self.mainTrack.insertTimeRange(
                    CMTimeRangeMake(start: .zero, duration: sceneVideoAsset.duration),
                    of: sceneVideoTrack,
                    at: .zero)
            } catch {
                // renders UGC without Scene
                UGCLogger.log(message: "Unable to add scene \(scene) to the UGC. Trouble insertTimeRange to mainTrack.")
                continue
            }
                    
            let sceneInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: sceneVideoTrack)
            self.durationTillNow = CMTimeAdd(self.durationTillNow, sceneVideoAsset.duration)
            
            if scene != self.scenes.last {
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
            completion(.failure(UGCError.exportFailedFatally))
            return
        }
        self.ugcExporter = exporter
        exporter.outputURL = self.displayURL
        exporter.outputFileType = self.renderSettings.outputFileType
        exporter.shouldOptimizeForNetworkUse = true
        exporter.videoComposition = self.outputComposition
        
        UGCLogger.log(message: "UGC Generated")
        exporter.exportAsynchronously {
            UGCLogger.log(message: "UGC Rendered ")
            switch exporter.status {
            
                case .completed:
                    completion(.success(
                        UGCSuccessResult(
                            displayURL: self.displayURL
                        )
                    ))
                case .cancelled, .failed: completion(.failure(.exportFailedOrCancelled))
                default: completion(.failure(.unknown))
            }

            durationLogger.finish()
        }
    }
}
