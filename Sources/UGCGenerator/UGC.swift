//
//  UGC.swift
//  UCGCreator
//
//  Created by Brian Anglin on 2/9/21.
//

import Foundation
import AVFoundation
import UIKit

public class UGC: UGCSceneDelegate
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
    
    public func createSceneConfiguration() -> UGCScene
    {
        let sceneConfiguration = UGCScene(delegate: self, renderSettings: self.renderSettings)
        sceneConfigurations.append(sceneConfiguration)
        sceneRenderingResults.append(nil)
        return sceneConfiguration
    }
    
    public func ready(completion: UGCResultCompletion? = nil)
    {
        // Wait until all the scenes we've created are ready
        sceneRenderingWaitGroup.notify(queue: .main) {
            // Actually render the UGC
            self.renderUGC(retries: 3, completion: completion)
        }
    }

    @discardableResult
    public func presentUGC(on viewController: UIViewController, view: UIView) -> Swift.Error?
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
    
    //MARK: Private Rendering
    
    private func renderUGC(retries: Int = 3, completion: UGCResultCompletion?)
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
                self.renderUGC(retries: retries - 1, completion: completion)
            }
            else
            {
                delegate?.didFinish(result: .failure(error))
                completion?(.failure(error))
            }
            return
        } catch {
            delegate?.didFinish(result: .failure(.unknown))
            completion?(.failure(.unknown))
            return
        }

        ugc.startExport() {
            (result) in
            switch(result)
            {
            case .success(let result):
                self.delegate?.didFinish(result: .success(result))
                completion?(.success(result))
            case .failure(let error):
                if(error.retryable && retries > 0)
                {
                    self.renderUGC(retries: retries - 1, completion: completion)
                }
                else
                {
                    self.delegate?.didFinish(result: .failure(error))
                    completion?(.failure(error))
                }
            }
        }
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
