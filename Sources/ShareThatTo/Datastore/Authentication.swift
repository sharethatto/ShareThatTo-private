//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/9/21.
//

import Foundation


protocol AuthenticationDatastoreProtocol {
    var apiKey: String? { get set }
}

class AuthenticationDatastore: AuthenticationDatastoreProtocol
{
    internal static let shared = AuthenticationDatastore()
    var apiKey: String?
    
    private init() {
        apiKey = Bundle.main.shareThatToClientId
        if (apiKey == nil)
        {
            Logger.shareThatToDebug(string: "[AuthenticationDatastore ShareThatToClientId] ShareThatToClientId is not set, please update your Info.plist", error: nil, documentation: .apiKeyNotSet)
        }
    }
}
