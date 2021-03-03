//
//  File.swift
//  
//
//  Created by Brian Anglin on 3/2/21.
//

import Foundation
class UGCImageLayerConfiguration: UGCLayerConfiguration
{
    
    public let format: UGCImageFormat
    public let url: URL
    
    public init(format: UGCImageFormat, url: URL)
    {
        self.format = format
        self.url = url
    }
    
    override public func build(scene: UGCSecneRenderer) throws
    {
        try UGCImageLayerBuilder.build(configuration: self, scene: scene)
    }
}

