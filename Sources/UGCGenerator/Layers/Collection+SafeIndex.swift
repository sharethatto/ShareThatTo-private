//
//  File.swift
//  
//
//  Created by Brian Anglin on 3/13/21.
//

import Foundation

// https://www.vadimbulavin.com/handling-out-of-bounds-exception/
internal extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
