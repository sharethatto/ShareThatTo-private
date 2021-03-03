//
//  File.swift
//  
//
//  Created by Brian Anglin on 3/2/21.
//

import Foundation

class UGCTextLayerConfiguration: UGCLayerConfiguration
{
    
    public let format: UGCTextFormat
    public let parameters: [String:String]
    
    public init(format: UGCTextFormat, parameters: [String:String])
    {
        self.format = format
        self.parameters = parameters
    }
    
    override public func build(scene: UGCSecneRenderer)
    {
        UGCTextLayerBuilder.build(configuration: self, scene: scene)
    }
}
