//
//  File.swift
//  
//
//  Created by Brian Anglin on 3/13/21.
//

import UIKit
import Foundation

internal class UGCPresentation
{
    weak var view: UIView!
    weak var viewController: UIViewController!
    weak var ugc: UGC?
    
    private var sceneIndex: Int = 0
    public init(ugc: UGC)
    {
        self.ugc = ugc
    }
    
    public func stopPresenting()
    {
        
    }
    
    public func present(on viewController: UIViewController, view: UIView) throws
    {
        try present(index: sceneIndex, viewController: viewController, view: view)
    }
    
    private func present(index: Int, viewController: UIViewController, view: UIView) throws
    {
        guard let ugc = self.ugc else { return }
        guard let scene = ugc.sceneConfigurations[safe: sceneIndex] else {
            UGCLogger.log(message: "Unable to present ugc, no scene for index \(sceneIndex)")
            return
        }
        
        scene.presentScene(on: viewController, view: view) {
            // Done showing the video
            self.sceneIndex += 1
            if (self.sceneIndex >= ugc.sceneConfigurations.count)
            {
                self.sceneIndex = 0
            }
            do {
                try self.present(on: viewController, view: view)
            } catch {
                UGCLogger.log(message: "Got error presting")
            }
        }
    }
    
}
