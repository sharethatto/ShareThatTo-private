//
//  File.swift
//  
//
//  Created by Brian Anglin on 3/2/21.
//
import UIKit
import Foundation

class UGCTextLayerBuilder: UGCLayerBuilder
{
    public static func build(configuration: UGCTextLayerConfiguration, scene: UGCSecne)
    {
        var outputText = configuration.format.textTemplate
        for (name, value) in configuration.parameters {
            outputText = outputText.replacingOccurrences(of: "{{\(name)}}", with: value)
        }
        
        let textLayer = UGCTextLayer()
        configuration.format.appendAttribute(.string(outputText))
        textLayer.applyAttributes(layerAttributes: configuration.format.attributes)
        
        textLayer.borderWidth = 4
        textLayer.borderColor = UIColor.red.cgColor
        
        textLayer.backgroundColor = UIColor.green.cgColor
        
        if (textLayer.defaultPlacements == true){
            textLayer.transformToExpectedLayerPlacement(
                outputLayerSize: scene.outputLayer.frame.size
            )
        }
        
        scene.outputLayer.addSublayer(textLayer)
        textLayer.displayIfNeeded()
    }
}
