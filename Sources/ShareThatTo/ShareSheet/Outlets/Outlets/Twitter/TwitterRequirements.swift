//
//  File.swift
//  
//
//  Created by Brian Anglin on 3/3/21.
//

import Foundation
class TwitterRequirements: Requirements
{
    public init()
    {
        super.init(requirements: [
            RequiredApplicationQuerySchemes(requiredSchemes: [
                "twitter",
            ])
        ])
    }
}
