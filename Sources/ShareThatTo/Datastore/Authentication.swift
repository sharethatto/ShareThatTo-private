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
}
