//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/6/21.
//

import Foundation

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
    
    var applicationQuerySchemes: [String] {
        return infoDictionary?["LSApplicationQueriesSchemes"] as? [String] ?? []
    }
}
