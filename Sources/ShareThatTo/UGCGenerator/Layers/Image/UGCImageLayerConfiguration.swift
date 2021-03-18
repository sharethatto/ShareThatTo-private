//
//  File.swift
//  
//
//  Created by Brian Anglin on 3/2/21.
//

import UIKit    
import Foundation

internal class UGCImageLayerConfiguration: UGCLayerConfiguration
{
    
    internal let format: UGCImageFormat
    internal var url: URL? = nil
    internal var image: UIImage? = nil
    
    public init(format: UGCImageFormat, url: URL)
    {
        self.format = format
        self.url = url
    }
    
    public init(format: UGCImageFormat, image: UIImage)
    {
        self.format = format
        self.image = image
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

