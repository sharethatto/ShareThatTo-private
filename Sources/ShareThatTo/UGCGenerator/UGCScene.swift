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

public enum UGCSceneOption
{
    case maxDuration(Double)
}

public struct UGCSceneOptions
{
    var maxDuration: Double?
    init(options: [UGCSceneOption] = [])
    {
        for option in options
        {
            switch (option) {
            case .maxDuration(let value):
                self.maxDuration = value
            }
        }
    }
}

internal protocol UGCSceneContext
{
    var sceneIdentifier: String { get }
    var sceneDispatchQueue: DispatchQueue { get }
}

enum UGCLayerInstruction
{
    case imageLitearl(UGCImageFormat, UIImage)
    case imageURL(UGCImageFormat, URL)
    case videoURL(UGCVideoFormat, URL)
    case text(UGCTextFormat, String)
}

public class UGCScene:  UGCSceneContext
{
    internal var configurations: [UGCLayerConfiguration] = []
    internal let renderSettings: UGCRenderSettings
    internal let sceneOptions: UGCSceneOptions
    private weak var delegate: UGCSceneDelegate?
    
    internal var sceneIdentifier: String = UUID().uuidString
    internal var sceneDispatchQueue: DispatchQueue
    
    private let configurationReadyDispatchGroup = DispatchGroup()
    internal init(delegate: UGCSceneDelegate, renderSettings: UGCRenderSettings, sceneOptions: [UGCSceneOption] = [])
    {
        self.delegate = delegate
        self.renderSettings = renderSettings
        self.sceneOptions =  UGCSceneOptions(options: sceneOptions)
        self.sceneDispatchQueue = .init(label: "UGCScene-\(sceneIdentifier)")
    }
    
    public init(renderSettings: UGCRenderSettings, _ sceneOptions: UGCSceneOption...)
    {
        self.renderSettings = renderSettings
        self.sceneOptions = UGCSceneOptions(options: sceneOptions)
        self.sceneDispatchQueue = .init(label: "UGCScene-\(sceneIdentifier)")
    }
    
    //MARK: Public Interface
    @discardableResult
    public func imageLayer(format: UGCImageFormat, url: URL) -> UGCScene {
        configurations.append(UGCURLImageLayerConfiguration(format: format, url: url))
        return self
    }
    
    @discardableResult
    public func imageLayer(format: UGCImageFormat, image: UIImage) -> UGCScene {
        configurations.append(UGCUIImageLayerConfiguration(format: format, image: image))
        return self
    }

    @discardableResult
    public func videoLayer(format: UGCVideoFormat, url: URL) -> UGCScene {
        configurations.append(UGCVideoLayerConfiguration(format: format, url: url))
        return self
    }
    
    @discardableResult
    public func textLayer(format: UGCTextFormat, text: String) -> UGCScene {
        configurations.append(UGCTextLayerConfiguration(format: format, text: text))
        return self
    }
    
    private var configurationsFailed: Bool = false
    
    public func ready(completion: UGCResultCompletion? = nil)
    {
        sceneDispatchQueue.async { if (self.configurationsFailed) { return } }
        
        delegate?.sceneReady(configuration: self)
        
        // Make sure all completions are ready to go!
        for configuration in configurations {
            configurationReadyDispatchGroup.enter()
                configuration.ready {
                    (error) in
                    if let _ = error {
                        self.sceneDispatchQueue.async {
                            self.configurationsFailed = true
                        }
                        // TODO: Have a way to break out of this operation here
                    }
                    self.configurationReadyDispatchGroup.leave()
                }
        }
        

        configurationReadyDispatchGroup.notify(queue: sceneDispatchQueue) {
            // Stop us from continuing to render
            if (self.configurationsFailed)
            {
                 return
            }
            self.renderScene(retries: 3, completion: completion)
        }
    }
    
    //MARK: Private Rendering
    
    @discardableResult
    public func presentScene(on viewController: UIViewController, view: UIView, completion: UGCPresentationCompletion? = nil) -> Swift.Error?
    {
        do {
            let presentation = UGCScenePresentation(scene: self)
            try  presentation.present(on: viewController, view: view, completion: completion)
        } catch let error as UGCError {
            return error
        } catch let error {
            return error
        }
        return nil
    }
    
    private func renderScene(retries: Int = 3, completion: UGCResultCompletion? = nil)
    {
        DispatchQueue.main.async {
        
            let scene: UGCSecneRenderer
            do {
                scene = try UGCSecneRenderer(scene: self)
            } catch let error as UGCError {
                // Propogate configuration errors
                self.delegate?.sceneDidRender(configuration: self, result: .failure(error))
                DispatchQueue.main.async { completion?(.failure(error)) }
                return
            } catch {
                self.delegate?.sceneDidRender(configuration:self, result: .failure(.unknown))
                DispatchQueue.main.async { completion?(.failure(.unknown)) }
                return
            }

            scene.sceneReady() {
                (result) in
                switch(result)
                {
                case .success(let result):
                    self.delegate?.sceneDidRender(configuration: self, result: .success(result))
                    DispatchQueue.main.async { completion?(.success(result)) }
                case .failure(let error):
                    if(error.retryable && retries > 0)
                    {
                        self.renderScene(retries: retries - 1)
                    }
                    else
                    {
                        self.delegate?.sceneDidRender(configuration: self, result: .failure(error))
                        DispatchQueue.main.async { completion?(.failure(error)) }
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
