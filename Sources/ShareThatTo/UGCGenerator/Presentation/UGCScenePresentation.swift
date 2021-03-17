//
//  File.swift
//  
//
//  Created by Brian Anglin on 3/9/21.
//

import UIKit
import AVKit
import Foundation



internal class UGCScenePresentationViewController: UIViewController
{
    private var deinitBlocks: [() -> Void] = []
    private weak var presentation: UGCScenePresentation?
    init(presentation: UGCScenePresentation)
    {
        self.presentation = presentation
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func removeSelfAndOtherViews()
    {
        guard let viewController = self.parent else { return }
        if viewController.children.count > 0
        {
            let viewControllers:[UIViewController] = viewController.children
            for viewContoller in viewControllers
            {
                viewContoller.willMove(toParent: nil)
                viewContoller.view.removeFromSuperview()
                viewContoller.removeFromParent()
           }
        }
        presentation?.view.removeFromSuperview()
    }
    
    public func videoDidFinish()
    {
        removeSelfAndOtherViews()
        guard let presentation = presentation else { return }
        presentation.delegate?.sceneDidFinsih(scene: presentation)
        presentation.completion?()
    }
    
    deinit
    {
        for deinitBlock in deinitBlocks
        {
            deinitBlock()
        }
    }
    
    public func registerDeinit(completion: @escaping () -> Void)
    {
        deinitBlocks.append(completion)
    }
    
}

internal protocol UGCScenePresentationDelegate: class {
    func sceneDidFinsih(scene: UGCScenePresentation)
}

internal class UGCScenePresentation
{
    weak var view: UIView!
    weak var viewController: UIViewController!
    weak var scene: UGCScene?
    weak var presentationViewController: UGCScenePresentationViewController!
    
    weak var delegate: UGCScenePresentationDelegate?
    var completion: UGCPresentationCompletion?
    public init(scene: UGCScene)
    {
        self.scene = scene
    }

    public func present(on viewController: UIViewController, view: UIView, completion: UGCPresentationCompletion? = nil) throws
    {
        
        let presentationViewController = UGCScenePresentationViewController(presentation: self)
        self.presentationViewController = presentationViewController
        
        self.completion = completion
        
        self.viewController = viewController
        
        guard let scene = self.scene else { throw UGCError.unknown }
        let renderSettings = scene.renderSettings
        let configurations = scene.configurations
        
        // We have a view we're going to put our view into
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: renderSettings.size.width, height: renderSettings.size.height))
        self.view = containerView
        
        for configuration in configurations
        {
            try configuration.buildPresentation(presentation: self)
        }
        
        // This code scales the content to fit in the containing view
        // TODO: Support UIViewContentModeScaleAspectFit, UIViewContentModeScaleAspectFill
        // TODO: Support AVLayerVideoGravity 

        
        // Handle narrower content view
        let scale = view.frame.height / CGFloat(renderSettings.size.height)
        
        var transform = CGAffineTransform.identity
        let centeringXAdjustment =  CGFloat(renderSettings.size.width) * scale / 2.0  - view.frame.width / 2.0
        let translateX = CGFloat(-0.5) * (CGFloat(1) - scale) * (CGFloat(renderSettings.size.width)) - centeringXAdjustment
        
        let centeringYAdjustment = CGFloat(renderSettings.size.height) * scale / 2.0  - view.frame.height / 2.0
        let translateY = CGFloat(-0.5) * (CGFloat(1) - scale) * CGFloat(renderSettings.size.height) - centeringYAdjustment
        
        transform = transform.translatedBy(x: translateX, y: translateY)
        transform = transform.scaledBy(x: scale, y: scale)
        containerView.transform = transform
        containerView.layer.borderWidth = CGFloat(2)
        
        containerView.backgroundColor = UIColor(cgColor: renderSettings.backgroundColor)
        view.addSubview(containerView)
        
        viewController.addChild(presentationViewController)
    }
}
