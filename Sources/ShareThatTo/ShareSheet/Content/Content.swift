//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/3/21.
//

import Foundation

public enum ContentType: String {
    case unknown = "unknown"
    case video = "video"
}

public protocol Content
{
    var contentType: ContentType { get }
    
    // Content pL
    func videoContent() -> VideoContent?
    
    func cleanupContent(with usedStrategies:[ShareStretegyType])
}

extension Content
{
    // Handle force unwrapping here so we can guard it all our
    // outlet classes
    public func videoContent() -> VideoContent?
    {
        if (contentType == .video)
        {
            return self as? VideoContent
        }
        return nil
    }
    
    func cleanupContent(with usedStrategies:[ShareStretegyType])
    {
        //
    }
}
