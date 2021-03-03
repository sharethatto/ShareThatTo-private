//
//  File.swift
//  
//
//  Created by Brian Anglin on 3/2/21.
//


import Foundation
internal class UGCVideoLayerConfiguration: UGCLayerConfiguration
{
    
    let format: UGCVideoFormat
    let url: URL
    
    init(format: UGCVideoFormat, url: URL)
    {
        self.format = format
        self.url = url
    }
    
    override func build(scene: UGCSecneRenderer) throws
    {
        try UGCVideoLayerBuilder.build(configuration: self, scene: scene)
    }
}

