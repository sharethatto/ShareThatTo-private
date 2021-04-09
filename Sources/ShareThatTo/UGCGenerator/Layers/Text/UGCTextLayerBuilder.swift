//
//  File.swift
//  
//
//  Created by Brian Anglin on 3/2/21.
//
import UIKit
import Foundation

internal class UGCTextLayerBuilder: UGCLayerBuilder
{

    
    static func build(configuration: UGCTextLayerConfiguration, scene: UGCSecneRenderer)
    {

    
        
        let textLayer = CATextLayer()
        configuration.format.appendAttribute(.string(configuration.text))
        textLayer.applyAttributes(layerAttributes: configuration.format.attributes)
        
        scene.outputLayer.addSublayer(textLayer)
        textLayer.displayIfNeeded()
    }
    
    static func buildPresentation(configuration: UGCTextLayerConfiguration, presentation: UGCScenePresentation)
    {
        
        let textLayer = CATextLayer()
        configuration.format.appendAttribute(.string(configuration.text))
        textLayer.applyAttributes(layerAttributes: configuration.format.attributes)
        
        presentation.view.layer.addSublayer(textLayer)
        textLayer.displayIfNeeded()
    }
}
