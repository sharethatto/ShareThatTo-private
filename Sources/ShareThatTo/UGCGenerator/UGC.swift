//
//  UGC.swift
//  UCGCreator
//
//  Created by Brian Anglin on 2/9/21.
//

import Foundation
import AVFoundation
import UIKit


public class UGC: UGCSceneDelegate, Presentable
{
    private let renderSettings: UGCRenderSettings
    private let sceneRenderingWaitGroup = DispatchGroup()
    
    public weak var delegate: UGCResultDelegate?
    
    internal var sceneConfigurations: [UGCScene] = []
    internal var sceneRenderingResults: [UGCResult?] = []
    
    //MARK: Public
    public init(renderSettings: UGCRenderSettings)
    {
        self.renderSettings = renderSettings
    }
    
    public init(delegate: UGCResultDelegate, renderSettings: UGCRenderSettings)
    {
        self.delegate = delegate
        self.renderSettings = renderSettings
    }
    
    public func createSceneConfiguration(_ sceneOptions: UGCSceneOption...) -> UGCScene
    {
        let sceneConfiguration = UGCScene(delegate: self, renderSettings: self.renderSettings, sceneOptions: sceneOptions)
        sceneConfigurations.append(sceneConfiguration)
        sceneRenderingResults.append(nil)
        return sceneConfiguration
    }
    
    
    @discardableResult
    public func present(on viewController: UIViewController, view: UIView) -> Swift.Error?
    {
        do {
            let presentation = UGCPresentation(ugc: self)
            try  presentation.present(on: viewController, view: view)
        } catch let error as UGCError {
            return error
        } catch let error {
            return error
        }
        return nil
    }
    
    private var renderingResult: UGCResult? = nil
    private var renderingStarted: Bool = false
    private var completionConsumers: [UGCResultCompletion] = []
    
    
    public func ready(completion: UGCResultCompletion? = nil)
    {
        // Circuit break here if we've already finished rendering
        // This result will always be nil until we've finished rendering
        if let result = renderingResult {
            completion?(result)
            return
        }
        
        // TODO: Possible race here:
        // (A) The rendering was not done when we checked
        // (B) Finishes and the completions are called
        // (A) We now add the new completion to the list
        
        // Add a new watcher
        if let unwrappedCompletion = completion
        {
            completionConsumers.append(unwrappedCompletion)
        }
        
        // Only start this process once
        if (renderingStarted)
        {
            return
        }
        renderingStarted = true
        
        
        // Wait until all the scenes we've created are ready
        sceneRenderingWaitGroup.notify(queue: .main) {
            // Actually render the UGC
            self.renderUGC(retries: 3)
        }
    }

    
    //MARK: Private Rendering
    
    
    private func renderUGC(retries: Int = 3)
    {
        let results = self.sceneRenderingResults.compactMap { (result) -> UGCSuccessResult? in
            switch(result) {
            case .success(let result): return result
            default: return nil
            }
        }
        
        let ugc: UGCRenderer
        do {
            ugc = try UGCRenderer(scenes: results, renderSettings: renderSettings)
        } catch let error as UGCError {
            // Propogate configuration errors
            if(error.retryable && retries > 0)
            {
                self.renderUGC(retries: retries - 1)
            }
            else
            {
                self.renderingDidComplete(result: .failure(error))
            }
            return
        } catch {
            self.renderingDidComplete(result: .failure(.unknown))
            return
        }

        ugc.startExport() {
            (result) in
            switch(result)
            {
            case .success(let result):
                self.renderingDidComplete(result: .success(result))
            case .failure(let error):
                if(error.retryable && retries > 0)
                {
                    self.renderUGC(retries: retries - 1)
                }
                else
                {
                    self.renderingDidComplete(result: .failure(error))
                }
            }
        }
    }
    
    // Notify all the watchers
    private func renderingDidComplete(result: UGCResult)
    {
        self.renderingResult = result
        for completion in completionConsumers
        {
            completion(result)
        }
        delegate?.didFinish(result: result)
    }
    
    //MARK: UGCSceneDelegate
    
    internal func sceneDidRender(configuration: UGCScene, result: UGCResult)
    {
        let optionalIndex = sceneConfigurations.firstIndex(of: configuration)
        guard let index = optionalIndex else {
            // THIS SHOULD NEVER HAPPEN!
            sceneRenderingWaitGroup.leave() // I guess :shrug:
            return
        }
        sceneRenderingResults[index] = result
        sceneRenderingWaitGroup.leave()
    }
    
    internal func sceneReady(configuration: UGCScene)
    {
        sceneRenderingWaitGroup.enter()
    }
}

extension UGC: VideoContentFutureProvider
{
    public func startRendering()
    {
        ready()
    }
    
    public func renderingComplete(completion: @escaping (RenderingResult) -> Void)
    {
        // TODO: Since the completion signature is basically the same except
        // the UGC uses `UGCError` (which is as subclass of `Swift.Error`) we have to do this
        // grossness 
        ready() {
            (result) in
            switch(result) {
            case .success(let result):
                completion(.success(result))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
