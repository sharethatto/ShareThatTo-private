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
    internal var format: UGCImageFormat
    internal var url: URL? = nil
    internal var image: UIImage? = nil
    
    public init(format: UGCImageFormat)
    {
        self.format = format
    }
}

internal class UGCURLImageLayerConfiguration: UGCImageLayerConfiguration
{

    // We actually need to load here
    private let resource: Resource
    public init(format: UGCImageFormat, url: URL)
    {
        self.resource = Resource(identifier: url)
        super.init(format: format)
        self.resource.fetch()
        {
            (result) in
            switch (result) {
            case .success(let value):
                self.url = value
            default: break;
            }
        }
    }
    
    override public func build(scene: UGCSecneRenderer) throws
    {
        try UGCImageLayerBuilder.build(configuration: self, scene: scene)
    }
    
    override public func buildPresentation(presentation: UGCScenePresentation) throws
    {
        try UGCImageLayerBuilder.buildPresentation(configuration: self, presentation: presentation)
    }
    
    override func ready(completion: @escaping UGCConfigurationReadyCompletion)
    {
        self.resource.fetch()
        {
            (result) in
            switch (result) {
            case .success: completion(nil)
            case .failure(let error): completion(error)
            }
        }
    }
}

internal class UGCUIImageLayerConfiguration: UGCImageLayerConfiguration
{
    public init(format: UGCImageFormat, image: UIImage)
    {
        super.init(format: format)
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

