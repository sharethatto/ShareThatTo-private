//
//  File.swift
//  
//
//  Created by Brian Anglin on 3/2/21.
//


import Foundation
class UGCVideoLayerConfiguration: UGCLayerConfiguration
{
    
    public let format: UGCVideoFormat
    public let url: URL
    
    public init(format: UGCVideoFormat, url: URL)
    {
        self.format = format
        self.url = url
    }
    
    override public func build(scene: UGCSecneRenderer) throws
    {
        try UGCVideoLayerBuilder.build(configuration: self, scene: scene)
    }
}

