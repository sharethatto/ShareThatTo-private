//
//  File.swift
//  
//
//  Created by Brian Anglin on 3/2/21.
//

import Foundation

internal class UGCTextLayerConfiguration: UGCLayerConfiguration
{
    
    internal let format: UGCTextFormat
    internal let text: String
    
    internal init(format: UGCTextFormat, text: String)
    {
        self.format = format
        self.text = text
    }
    
    override internal func build(scene: UGCSecneRenderer)
    {
        UGCTextLayerBuilder.build(configuration: self, scene: scene)
    }
    
    override func buildPresentation(presentation: UGCScenePresentation) throws
    {
        try UGCTextLayerBuilder.buildPresentation(configuration: self, presentation: presentation)
    }
}
