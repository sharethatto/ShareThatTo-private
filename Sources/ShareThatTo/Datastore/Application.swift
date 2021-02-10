//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/9/21.
//

import Foundation

protocol ApplicationDatastoreProtocol
{
    var application: ApplicationResponse? { get set }
}

internal class ApplicationDatastore: ApplicationDatastoreProtocol
{
    internal static let shared = ApplicationDatastore()
    var application: ApplicationResponse?;
    public init() { }
}
