//
//  File.swift
//  
//
//  Created by Brian Anglin on 3/2/21.
//

import Foundation
internal class UGCImageLayerConfiguration: UGCLayerConfiguration
{
    
    internal let format: UGCImageFormat
    internal let url: URL
    
    public init(format: UGCImageFormat, url: URL)
    {
        self.format = format
        self.url = url
    }
    
    override public func build(scene: UGCSecneRenderer) throws
    {
        try UGCImageLayerBuilder.build(configuration: self, scene: scene)
    }
    
    override public func buildPresentation(presentation: UGCScenePresentation) throws
    {
        try UGCImageLayerBuilder.buildPresentation(configuration: self, presentation: presentation)
    }
}

