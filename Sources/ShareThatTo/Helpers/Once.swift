//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/6/21.
//

import Foundation

class Once<Input,Output> {
    let block:(Input)->Output?
    private var cache:Output? = nil

    init(_ block:@escaping (Input)->Output?) {
        self.block = block
    }

    func once(_ input:Input, defaultValue: Output) -> Output {
        // If the cache is nil, we're assuming we haven't run this before
        guard let resolved = self.cache else {
            
            // Try to resolve the value
            let outputOptional = self.block(input)
            
            // If we got a nil, apply the defualt value
            guard let output = outputOptional else {
                self.cache = defaultValue
                return defaultValue
            }
            self.cache = output
            return output
        }
        return resolved
    }
}
