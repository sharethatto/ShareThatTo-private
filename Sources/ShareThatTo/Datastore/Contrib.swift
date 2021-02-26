//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/14/21.
//

import Foundation
import Foundation


protocol ContribDatastoreProtocol {
    var userId: String? { get set }
}

class ContribDatastore: ContribDatastoreProtocol
{
    internal static let shared = ContribDatastore()
    var userId: String?
}
