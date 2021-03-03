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

internal protocol UGCSceneDelegate: class
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
        DispatchQueue.main.async {
        
            let scene: UGCSecneRenderer
            do {
                scene = try UGCSecneRenderer(configurations:self.configurations, renderSettings: self.renderSettings)
            } catch let error as UGCError {
                // Propogate configuration errors
                self.delegate?.sceneDidRender(configuration: self, result: .failure(error))
                return
            } catch {
                self.delegate?.sceneDidRender(configuration:self, result: .failure(.unknown))
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
}


extension UGCScene: Equatable
{
    public static func == (lhs: UGCScene, rhs: UGCScene) -> Bool
    {
        return lhs === rhs
    }
}




/*


 Origin Flipped
 https://stackoverflow.com/questions/5176737/calayer-frame-origin-y-is-flipped-0-is-at-the-bottom
 
 
 */
