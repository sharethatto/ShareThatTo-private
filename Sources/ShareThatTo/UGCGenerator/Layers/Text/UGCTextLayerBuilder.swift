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
    private static func renderText(configuration: UGCTextLayerConfiguration) -> String
    {
        return configuration.text
//        var outputText = configuration.format.textTemplate
//        for (name, value) in configuration.parameters {
//            outputText = outputText.replacingOccurrences(of: "{{\(name)}}", with: value)
//        }
//        return outputText
    }
    
    static func build(configuration: UGCTextLayerConfiguration, scene: UGCSecneRenderer)
    {

        let outputText = renderText(configuration: configuration)
        
        let textLayer = CATextLayer()
        configuration.format.appendAttribute(.string(outputText))
        textLayer.applyAttributes(layerAttributes: configuration.format.attributes)
        
        scene.outputLayer.addSublayer(textLayer)
        textLayer.displayIfNeeded()
    }
    
    static func buildPresentation(configuration: UGCTextLayerConfiguration, presentation: UGCScenePresentation)
    {
        let outputText = renderText(configuration: configuration)
        let textLayer = CATextLayer()
        configuration.format.appendAttribute(.string(outputText))
        textLayer.applyAttributes(layerAttributes: configuration.format.attributes)
        
        presentation.view.layer.addSublayer(textLayer)
        textLayer.displayIfNeeded()
    }
}
