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
    var url: URL?
    let resource: Resource
    
    init(format: UGCVideoFormat, url: URL)
    {
        self.format = format
        self.resource = Resource(identifier: url)
        super.init()
        // It's really important that this closure runs before the one in "ready"
        // b/c otherwise the video url won't be set. I _think_ it should be fifo
        // but this seems like an opportunity for a really subtle bug
        self.resource.fetch() {
            (result) in 
            switch(result) {
            case .success(let url): self.url = url
            default: break
            }
        }
    }
    
    override func build(scene: UGCSecneRenderer) throws
    {
        try UGCVideoLayerBuilder.build(configuration: self, scene: scene)
    }
    
    override func buildPresentation(presentation: UGCScenePresentation) throws
    {
        try UGCVideoLayerBuilder.buildPresentation(configuration: self, presentation: presentation)
    }
    
    override func ready(completion: @escaping UGCConfigurationReadyCompletion)
    {
        self.resource.fetch { (result) in
            switch  (result) {
            case .success: completion(nil)
            case .failure(let error): completion(error)
            }
        }
    }
}

