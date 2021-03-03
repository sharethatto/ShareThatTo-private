//
//  File.swift
//  
//
//  Created by Brian Anglin on 3/3/21.
//

import Foundation
class InstgramStoriesRequirements: Requirements
{
    public init()
    {
        super.init(requirements: [
            RequiredApplicationQuerySchemes(requiredSchemes: [
                "instagram-stories",
            ])
        ])
    }
}
