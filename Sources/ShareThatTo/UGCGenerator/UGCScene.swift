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

private protocol UGCSceneDelegate: class
{
    func sceneDidRender(configuration: UGCScene, result: UGCResult)
    func sceneReady(configuration: UGCScene)
}

public class UGCScene
{
    private var configurations: [UGCLayerConfiguration] = []
    private let renderSettings: UGCRenderSettings
    private weak var delegate: UGCSceneDelegate?
    internal init(delegate: UGCSceneDelegate, renderSettings: UGCRenderSettings) //ugc: UGC, orderInUgc: Int)
    {
        self.delegate = delegate
        self.renderSettings = renderSettings
    }
    
    //MARK: Public Interface
    
    public func withImageLayer(format: UGCImageFormat, url: URL) -> UGCScene {
        configurations.append(UGCImageLayerConfiguration(format: format, url: url))
        return self
    }

    public func withVideoLayer(format: UGCVideoFormat, url: URL) -> UGCScene {
        configurations.append(UGCVideoLayerConfiguration(format: format, url: url))
        return self
    }
    
    public func withTextLayer(format: UGCTextFormat, parameters: [String:String]) -> UGCScene {
        configurations.append(UGCTextLayerConfiguration(format: format, parameters: parameters))
        return self
    }
    
    public func ready()
    {
        delegate?.sceneReady(configuration: self)
        renderScene()
    }
    
    //MARK: Private Rendering
    
    private func renderScene(retries: Int = 3)
    {
        let scene: UGCSecneRenderer
        do {
            scene = try UGCSecneRenderer(configurations:configurations, renderSettings: renderSettings)
        } catch let error as UGCError {
            // Propogate configuration errors
            delegate?.sceneDidRender(configuration: self, result: .failure(error))
            return
        } catch {
            delegate?.sceneDidRender(configuration:self, result: .failure(.unknown))
            return
        }

        scene.sceneReady() {
            (result) in
            switch(result)
            {
            case .success(let result):
                self.delegate?.sceneDidRender(configuration: self, result: .success(result))
            case .failure(let error):
                if(error.retryable && retries > 0)
                {
                    self.renderScene(retries: retries - 1)
                }
                else
                {
                    self.delegate?.sceneDidRender(configuration: self, result: .failure(error))
                }
            }
        }
    }
}


extension UGCScene: Equatable
{
    public static func == (lhs: UGCScene, rhs: UGCScene) -> Bool
    {
        return lhs === rhs
    }
}

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


/*


 Origin Flipped
 https://stackoverflow.com/questions/5176737/calayer-frame-origin-y-is-flipped-0-is-at-the-bottom
 
 
 */
