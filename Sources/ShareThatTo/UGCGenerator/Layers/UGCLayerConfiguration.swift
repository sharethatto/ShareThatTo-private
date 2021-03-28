//
//  File.swift
//  
//
//  Created by Brian Anglin on 3/2/21.
//

import Foundation

typealias UGCConfigurationReadyCompletion =  (Swift.Error? ) -> ()

internal class UGCLayerConfiguration
{
    
    public func build(scene: UGCSecneRenderer) throws
    {
        //
    }
    
    public func buildPresentation(presentation: UGCScenePresentation) throws
    {
        //
    }
    
    public func ready(completion: @escaping UGCConfigurationReadyCompletion)
    {
        completion(nil)
    }
}


internal class UGCLayerBuilder
{

    
}
