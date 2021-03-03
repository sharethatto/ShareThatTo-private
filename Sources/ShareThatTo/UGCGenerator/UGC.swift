//
//  UGC.swift
//  UCGCreator
//
//  Created by Brian Anglin on 2/9/21.
//

import Foundation
import AVFoundation
import UIKit

public class UGCConfiguration: UGCSceneDelegate
{
    private let defaultVideoURL: URL
    private let renderSettings: UGCRenderSettings
    private let sceneRenderingWaitGroup = DispatchGroup()
    private weak var delegate: UGCResultDelegate?
    
    private var sceneConfigurations: [UCGSceneConfiguration] = []
    private var sceneRenderingResults: [UGCResult?] = []
    
    //MARK: Public
    
    public init(delegate: UGCResultDelegate, defaultVideoURL: URL, renderSettings: UGCRenderSettings)
    {
        self.delegate = delegate
        self.defaultVideoURL = defaultVideoURL
        self.renderSettings = renderSettings
    }
    
    public func createSceneConfiguration() -> UCGSceneConfiguration
    {
        let sceneConfiguration = UCGSceneConfiguration(delegate: self, renderSettings: self.renderSettings)
        sceneConfigurations.append(sceneConfiguration)
        sceneRenderingResults.append(nil)
        return sceneConfiguration
    }
    
    public func ready()
    {
        // Wait until all the scenes we've created are ready
        sceneRenderingWaitGroup.notify(queue: .main) {
            // Actually render the UGC
            self.renderUGC()
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
                delegate?.didFinish(result: .failure(error))
            }
            return
        } catch {
            delegate?.didFinish(result: .failure(.unknown))
            return
        }

        ugc.startExport() {
            (result) in
            switch(result)
            {
            case .success(let result):
                self.delegate?.didFinish(result: .success(result))
            case .failure(let error):
                if(error.retryable && retries > 0)
                {
                    self.renderUGC(retries: retries - 1)
                }
                else
                {
                    self.delegate?.didFinish(result: .failure(error))
                }
            }
        }
    }
    
    //MARK: UGCSceneDelegate
    
    internal func sceneDidRender(configuration: UCGSceneConfiguration, result: UGCResult)
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
    
    internal func sceneReady(configuration: UCGSceneConfiguration)
    {
        sceneRenderingWaitGroup.enter()
    }
}
