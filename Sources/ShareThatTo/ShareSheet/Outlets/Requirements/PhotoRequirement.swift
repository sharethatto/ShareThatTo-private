//
//  File.swift
//  
//
//  Created by Brian Anglin on 3/3/21.
//

import Foundation

public class PhotoRequirement: RequiredPlistNonNil
{
    required public init()
    {
        super.init(requiredKey: "NSPhotoLibraryUsageDescription")
    }
}
