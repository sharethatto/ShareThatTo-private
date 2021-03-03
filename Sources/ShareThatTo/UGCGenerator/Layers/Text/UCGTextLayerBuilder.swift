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
        var outputText = configuration.format.textTemplate
        for (name, value) in configuration.parameters {
            outputText = outputText.replacingOccurrences(of: "{{\(name)}}", with: value)
        }
        
        let textLayer = UGCTextLayer()
        configuration.format.appendAttribute(.string(outputText))
        textLayer.applyAttributes(layerAttributes: configuration.format.attributes)
        
        if (textLayer.defaultPlacements == true){
            textLayer.transformToExpectedLayerPlacement(
                outputLayerSize: scene.outputLayer.frame.size
            )
        }
        
        scene.outputLayer.addSublayer(textLayer)
        textLayer.displayIfNeeded()
    }
}
