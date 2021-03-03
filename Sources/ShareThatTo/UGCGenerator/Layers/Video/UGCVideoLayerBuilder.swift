//
//  File.swift
//  
//
//  Created by Brian Anglin on 3/2/21.
//


import AVFoundation
import UIKit
import Foundation


class UGCVideoLayerBuilder: UGCLayerBuilder
{
    public static func build(configuration: UGCVideoLayerConfiguration, scene: UGCSecne)
    {
        let durationLogger = DurationLogger.begin(prefix: "[UGCScene] withVideoLayer")
        
        let videoLayer = UGCVideoLayer()
        let videoAsset = AVAsset(url: configuration.url)
//        guard let sceneTrack = scene.sceneTrack else {
//            scene.status = .failed
//            Logger.log(message: "Unable to get video track from AVAsset.")
//            return
//        }
        
        guard let videoTrack = videoAsset.tracks(withMediaType: .video).first else {
            scene.status = .failed
            Logger.log(message: "Unable to get video track from AVAsset.")
            return
        }
        
        let videoInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: scene.sceneTrack)
        
        videoLayer.applyAttributes(layerAttributes: configuration.format.attributes)
        
        if (videoLayer.defaultPlacements == true){
            videoLayer.transformToExpectedLayerPlacement(
                outputLayerSize: scene.outputLayer.frame.size,
                assetSize: videoTrack.naturalSize
            )
        }
        
        let scaleFactor = UGCVideoLayer.transformToExpectedAssetScale(
            outputLayerSize: scene.outputLayer.frame.size,
            outputFrameSize: videoLayer.frame.size,
            assetSize: videoTrack.naturalSize
        )
        
        videoInstruction.setTransform(scaleFactor, at: .zero)

        do {
            try scene.sceneTrack.insertTimeRange(
                CMTimeRangeMake(start: .zero, duration: videoAsset.duration),
                of: videoTrack,
                at: .zero)
        } catch {
            scene.status = .failed
            Logger.log(message: "Cannot insertTimeRange into scene Track.")
            return
        }

        
        scene.sceneDuration = videoAsset.duration
        print("[VideoLayerBuilder] before composition")
        scene.sceneOutputComposition.animationTool = AVVideoCompositionCoreAnimationTool(
            postProcessingAsVideoLayer: videoLayer,
            in: scene.outputLayer)
        print("[VideoLayerBuilder] after composition \(scene.sceneOutputComposition.animationTool)")
        scene.sceneOutputInstruction.layerInstructions.append(videoInstruction)
        scene.outputLayer.addSublayer(videoLayer)
        
        durationLogger.finish()
    }
}
