//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/3/21.
//

import Foundation

enum ContentType: String {
    case unknown = "unknown"
    case video = "video"
}

protocol Content
{
    var contentType: ContentType { get }
    
    // Content pL
    func videoContent() -> VideoContent?
}

extension Content
{
    // Handle force unwrapping here so we can guard it all our
    // outlet classes
    func videoContent() -> VideoContent?
    {
        if (contentType == .video)
        {
            return self as? VideoContent
        }
        return nil
    }
}
