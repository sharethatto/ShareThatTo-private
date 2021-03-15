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
        Download.self,
        Twitter.self,
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
    
    internal static func outlets(forPeformableType contentType:ContentType) -> [ShareOutletProtocol.Type]
    {
        var outlets: [ShareOutletProtocol.Type] = []
        for outletClass in availableOutlets {
            if (outletClass.canPerform(withContentType: contentType))
            {
                outlets.append(outletClass)
            }
        }
        return outlets
    }
}

public protocol ShareOutletDelegate {
    func success(shareOutlet: ShareOutletProtocol, strategiesUsed: [ShareStretegyType])
    func failure(shareOutlet: ShareOutletProtocol, error: String)
    func cancelled(shareOutlet: ShareOutletProtocol)
}


// TODO: Refactor so the outlet logic is disconnected from the actual view logic
public protocol ShareOutletProtocol
{
    static var outletLifecycleDelegate: ShareThatToLifecycleDelegate? { get }
    var delegate: ShareOutletDelegate? { get set }
    var content: Content { get set }
    
    // Configuration before instantiation
    static var imageName: String { get }
    static var outletName: String { get }
    static var canonicalOutletName: String { get }
    
    static var requirements: ShareOutletRequirementProtocol? { get }
    
    static func buttonImage() -> UIImage?
//    static func canPerform(withContent content:Content) -> Bool;
    static func canPerform(withContentType contentType:ContentType) -> Bool;
    
    // Initialize with the content
    // TODO: Ensure there is some content available to share before allowing init
    init(content: Content)
    
    // Actually present the view controller and try and share the content
    func share(with viewController: UIViewController);
}

extension ShareOutletProtocol
{
    static var requirements: ShareOutletRequirementProtocol? {
        get { nil }
    }
    
    // Right now we can only perform with video content
    static func canPerform(withContentType contentType:ContentType) -> Bool
    {
        if let reqs = requirements {
            if (!reqs.met(plist: Bundle.main.infoDictionary ?? [:]))
            {
                Logger.shareThatToDebug(string: "Can't enable outlet \(type(of: self)) please check plist", error: nil, documentation: .plitRequirementsNotMet)
                return false
            }
        }
        if (contentType == .video)
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


