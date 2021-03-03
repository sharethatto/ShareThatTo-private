//
//  File.swift
//  
//
//  Created by Brian Anglin on 3/3/21.
//

import Foundation
import AVFoundation
import UIKit

internal class UGCSecneRenderer
{
    var sceneDuration : CMTime?
    var sceneExporter : AVAssetExportSession?
    
    // Video compositions elementes
    private var sceneComposition : AVMutableComposition
    
    internal var sceneTrack: AVMutableCompositionTrack
    internal var sceneOutputComposition : AVMutableVideoComposition
    internal var sceneOutputInstruction : AVMutableVideoCompositionInstruction
    internal var layerInstruction : AVVideoCompositionLayerInstruction
    internal var outputLayer : CALayer

    // Passed Variables
    internal let displayURL: URL
    internal let renderSettings: UGCRenderSettings
    private let configurations: [UGCLayerConfiguration]
    internal init(configurations: [UGCLayerConfiguration], renderSettings: UGCRenderSettings) throws {
        self.configurations = configurations
        self.renderSettings = renderSettings

        
        guard let outputURL = ContentHelper.createFileURL(filename: UUID().uuidString,
                                                          filenameExt: renderSettings.filenameExt) else {
            throw UGCError.unknown
        }
        
        self.displayURL = outputURL

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
            throw UGCError.unknown
        }
        self.sceneTrack = sceneTrack
        
        for configuration in configurations {
            try configuration.build(scene: self)
        }
    }
    
    public func sceneReady(completion: @escaping UGCResultCompletion)
    {
        let durationLogger = DurationLogger.begin(prefix: "[UGCScene] sceneReady")
        
        guard let sceneDuration = self.sceneDuration else {
            completion(.failure(.noDuration))
            return
        }
        self.sceneOutputInstruction.timeRange = CMTimeRangeMake(
            start: .zero,
            duration: sceneDuration
        )
        
        self.sceneOutputComposition.instructions = [self.sceneOutputInstruction]
        self.sceneOutputComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        self.sceneOutputComposition.renderSize = self.renderSettings.size
                
        guard let exporter = AVAssetExportSession(
            asset: self.sceneComposition,
          presetName: AVAssetExportPresetHighestQuality
        ) else {
            completion(.failure(.exportFailedFatally))
            return
        }
        self.sceneExporter = exporter
        
        self.sceneExporter?.outputURL = displayURL
        self.sceneExporter?.outputFileType = self.renderSettings.outputFileType
        self.sceneExporter?.shouldOptimizeForNetworkUse = true
        self.sceneExporter?.videoComposition = self.sceneOutputComposition
        
        self.sceneExporter?.exportAsynchronously {
            switch self.sceneExporter?.status {
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
