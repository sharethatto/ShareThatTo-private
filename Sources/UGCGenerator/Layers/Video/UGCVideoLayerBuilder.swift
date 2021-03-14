//
//  File.swift
//  
//
//  Created by Brian Anglin on 3/2/21.
//



import UIKit
import AVKit
import Foundation


internal class UGCVideoLayerBuilder: UGCLayerBuilder
{
    static func buildPresentation(configuration: UGCVideoLayerConfiguration, presentation: UGCScenePresentation) throws
    {
        let videoLayer = CALayer()
        videoLayer.applyAttributes(layerAttributes: configuration.format.attributes)
        
        let videoAsset = AVAsset(url: configuration.url)
        
        guard let videoTrack = videoAsset.tracks(withMediaType: .video).first else {
            throw UGCError.videoError(message: "Unable to load video asset")
        }
        
        let avPlayer = AVPlayerViewController()
        let playerItem = AVPlayerItem(asset: videoAsset)
        
        
        let observer = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: .main) { _ in
            presentation.presentationViewController.videoDidFinish()
        }
        
        presentation.presentationViewController.registerDeinit {
            NotificationCenter.default.removeObserver(observer)
        }

        avPlayer.player = AVPlayer(playerItem: playerItem)
        presentation.view.addSubview(avPlayer.view)
        avPlayer.view.translatesAutoresizingMaskIntoConstraints = false

        avPlayer.view.frame = videoLayer.frame
        
        avPlayer.showsPlaybackControls = false
        avPlayer.player?.play()
        
        presentation.viewController.addChild(avPlayer)
    }
    
    static func build(configuration: UGCVideoLayerConfiguration, scene: UGCSecneRenderer) throws
    {
        let durationLogger = UGCDurationLogger.begin(prefix: "[UGCScene] withVideoLayer")
        
        let videoLayer = CALayer()
        let videoAsset = AVAsset(url: configuration.url)

        guard let videoTrack = videoAsset.tracks(withMediaType: .video).first else {
            throw UGCError.videoError(message: "Unable to load video asset")
        }
        
        let videoInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: scene.sceneTrack)
        videoLayer.applyAttributes(layerAttributes: configuration.format.attributes)
        
        let scaleFactor = videoLayer.transformToExpectedAssetScale(
            outputLayerSize: scene.outputLayer.frame.size,
            assetSize: videoTrack.naturalSize
        )
        
        videoInstruction.setTransform(scaleFactor, at: .zero)
        
        // Grab the duration
        
        let duration: CMTime
        if let maxDuration = scene.sceneOptions.maxDuration
        {
            duration = CMTime(value: CMTimeValue(maxDuration), timescale: 30)
        }
        else
        {
            duration = videoAsset.duration
        }
            
        do {
            try scene.sceneTrack.insertTimeRange(
                CMTimeRangeMake(start: .zero, duration: duration),
                of: videoTrack,
                at: .zero)
        } catch {
            throw UGCError.videoError(message: "Unable to insert video track")
        }

        scene.sceneDuration = videoAsset.duration
        scene.sceneOutputComposition.animationTool = AVVideoCompositionCoreAnimationTool(
            postProcessingAsVideoLayer: videoLayer,
            in: scene.outputLayer)
        scene.sceneOutputInstruction.layerInstructions.append(videoInstruction)
        scene.outputLayer.addSublayer(videoLayer)
        
        durationLogger.finish()
    }
}
