//
//  File.swift
//  
//
//  Created by Brian Anglin on 3/3/21.
//

import Foundation
class InstagramFeedRequirements: Requirements
{
    public init()
    {
        super.init(requirements: [
            PhotoRequirement(),
            RequiredApplicationQuerySchemes(requiredSchemes: [
                "instagram",
            ]),
        ])
    }
}
