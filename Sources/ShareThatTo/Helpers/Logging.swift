//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/26/21.
//

import Foundation
func shareThatToDebug(string: String, error: Swift.Error? = nil)
{
    print("[ShareThatTo] " + string + (error == nil ? "" : " - " + (error?.localizedDescription ?? "")))
}
