//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/9/21.
//

import Foundation


struct Datastore {
    public static let shared = Datastore()
    
    var applicationDatastore: ApplicationDatastoreProtocol
    var authenticationDatastore: AuthenticationDatastoreProtocol
    var contribDatastore: ContribDatastoreProtocol
    public init(
        applicationDatastore: ApplicationDatastoreProtocol = ApplicationDatastore.shared,
        authenicationDatastore: AuthenticationDatastoreProtocol = AuthenticationDatastore.shared,
        contribDatastore: ContribDatastoreProtocol = ContribDatastore.shared
    )
    {
        self.applicationDatastore = applicationDatastore
        self.authenticationDatastore = authenicationDatastore
        self.contribDatastore = contribDatastore
    }   
}
