//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/3/21.
//

import UIKit
import Foundation

class ShareOutlets
{
    internal static var availableOutlets: [ShareOutletProtocol.Type] = [
        IMessage.self,
        InstagramStories.self,
        Messenger.self,
        Download.self,
        Twitter.self,
        Facebook.self,
        InstagramFeed.self,
        More.self,
        Copy.self,
    ]
    
    internal static func forwardLifecycleDelegate(callable: (ShareThatToLifecycleDelegate) -> Void)
    {        
        for outlet in availableOutlets {
            guard let outletLifecycleDelegate = outlet.outletLifecycleDelegate else { continue}
            callable(outletLifecycleDelegate)
        }
    }
    
    internal static func outlets(forPeformable content:Content) -> [ShareOutletProtocol]
    {
        var outlets: [ShareOutletProtocol] = []
        for outletClass in availableOutlets {
            if (outletClass.canPerform(withContent: content)){
                let outlet = outletClass.init(content: content)
                outlets.append(outlet)
            }
        }
        return outlets
    }
}

public protocol ShareOutletDelegate {
    func success(shareOutlet: ShareOutletProtocol, strategiesUsed: [ShareStretegyType])
//    func success(shareOutlet: ShareOutletProtocol)
    func failure(shareOutlet: ShareOutletProtocol, error: String)
    func cancelled(shareOutlet: ShareOutletProtocol)
}

//extension ShareOutletDelegate
//{
//    func success(shareOutlet: ShareOutletProtocol, strategiesUsed: [ShareStretegyType])
//    {
//        self.success(shareOutlet: shareOutlet)
//    }
//}

public protocol ShareOutletProtocol {
    static var outletLifecycleDelegate: ShareThatToLifecycleDelegate? { get }
    var delegate: ShareOutletDelegate? { get set }
    var content: Content { get set }
    
    // Configuration before instantiation
    static var imageName: String { get }
    static var outletName: String { get }
    static var canonicalOutletName: String { get }
//    static var requirements: ShareOutletRequirementProtocol { get }
    static func buttonImage() -> UIImage?
    static func canPerform(withContent content:Content) -> Bool;
    
    // Initialize with the content
    init(content: Content)
    
    // Actually present the view controller and try and share the content
    func share(with viewController: UIViewController);
}

extension ShareOutletProtocol
{
    // Right now we can only perform with video content
    static func canPerform(withContent content: Content) -> Bool
    {
        if (content.contentType == .video)
        {
            return true
        }
        return false
    }
    
    static func buttonImage() -> UIImage?
    {
        guard let filepath = Bundle.module.path(forResource: "Assets/" + imageName, ofType: ".png") else {
            return nil
        }
        return UIImage(contentsOfFile: filepath)
    }
}


