//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/26/21.
//

import Foundation


internal struct Logger
{
    static func shareThatToDebug(string: String, error: Swift.Error? = nil, documentation: DocumentationIdentifier? = nil )
    {
        print("[ShareThatTo] " + string + Logger.errorString(error: error) + Logger.docsLinkString(documentation: documentation))
    }
    
    private static func errorString(error: Swift.Error?) -> String
    {
        return error == nil ? "" : " - " + (error?.localizedDescription ?? "")
    }
    
    private static func docsLinkString(documentation: DocumentationIdentifier?) -> String
    {
        return documentation == nil ? "" : " - " +  (buildDocsLink(documentation:documentation) ?? "")
    }
    
    private static func buildDocsLink(documentation: DocumentationIdentifier?) -> String?
    {
        guard let doc = documentation else {
            return nil
        }
        return "https://app.sharethat.to/docs?id=\(doc.rawValue)"
    }
}

