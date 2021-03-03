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
    internal let parameters: [String:String]
    
    internal init(format: UGCTextFormat, parameters: [String:String])
    {
        self.format = format
        self.parameters = parameters
    }
    
    override internal func build(scene: UGCSecneRenderer)
    {
        UGCTextLayerBuilder.build(configuration: self, scene: scene)
    }
}
