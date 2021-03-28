//
//  UGC.swift
//  UCGCreator
//
//  Created by Brian Anglin on 2/9/21.
//

import Foundation
import AVFoundation
import UIKit


public class UGC: UGCSceneDelegate, Presentable, TitleProvider
{
    public let renderSettings: UGCRenderSettings
    public var title: String?
    private let sceneRenderingWaitGroup = DispatchGroup()
    
    public weak var delegate: UGCResultDelegate?
    
    internal var sceneConfigurations: [UGCScene] = []
    internal var sceneRenderingResults: [UGCResult?] = []
    
    //MARK: Public
    
    convenience public init(title: String, _ options: UGCRenderOptions...)
    {
        self.init(title:title, options: options)
    }
    
    convenience public init(_ options: UGCRenderOptions...)
    {
        self.init(title:nil, options: options)
    }
    
    private init(title: String?, options: [UGCRenderOptions] = [])
    {
        self.title = title
        self.renderSettings = UGCRenderSettings(options)
    }
    
    public func createSceneConfiguration(_ sceneOptions: UGCSceneOption...) -> UGCScene
    {
        let sceneConfiguration = UGCScene(delegate: self, renderSettings: self.renderSettings, sceneOptions: sceneOptions)
        sceneConfigurations.append(sceneConfiguration)
        sceneRenderingResults.append(nil)
        return sceneConfiguration
    }
    
    
    public func present(on viewController:UIViewController, presentationStyle: PresentationStyle = .shareSheet, completion: SharePresentationCompletion? = nil)
    {
        switch presentationStyle
        {
            case .shareSheet: presentShareSheet(on: viewController, completion:  completion)
            case .toast: presentToast(on: viewController, completion: completion)
        }
    }
    
    private func presentToast(on viewController:UIViewController, completion: SharePresentationCompletion? = nil)
    {
        // TODO: Handle completion passing for Action
        DispatchQueue.main.async {
            let toastSize = CGFloat(0.8)
            let toastXOffset = CGFloat((1-toastSize)/2)
            let toast = UIButton()
            toast.frame = CGRect(x: viewController.view.bounds.width * toastXOffset , y: -60, width: viewController.view.bounds.width * toastSize , height: 60)
            toast.backgroundColor = .white
            toast.setTitle("Click to view workout recap", for: .normal)
            toast.setTitleColor(.black, for: .normal)
            toast.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
            toast.layer.cornerRadius = 30
//            toast.addTarget(self, action: <#T##Selector#>, for: <#T##UIControl.Event#>)
            viewController.view.addSubview(toast)
            toast.transform = .identity
            UIView.animate(withDuration: 0.15, delay: 0.0, options: [.curveLinear],
                           animations: { () -> Void in
                                toast.transform = CGAffineTransform(translationX: 0, y: 120)
                           }
            )
            UIView.animate(withDuration: 0.15, delay: 5.0, options: [.curveLinear],
                           animations: { () -> Void in
                                toast.transform = CGAffineTransform(translationX: 0, y: -120)
                           }
            ) { (animationCompleted: Bool) -> Void in
                toast.removeFromSuperview()
            }
        }
    }
    
    private func presentShareSheet(on viewController:UIViewController, completion: SharePresentationCompletion? = nil)
    {
        DispatchQueue.main.async {
            let vc = ShareSheetViewController.init(provider: self, completion: completion)
            viewController.present(vc, animated: true)
        }
    }
    
    @discardableResult
    public func presentOn(viewController: UIViewController, view: UIView) -> Swift.Error?
    {
        do {
            let presentation = UGCPresentation(ugc: self)
            try  presentation.presentOn(viewController: viewController, view: view)
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

