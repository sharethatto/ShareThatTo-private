//
//  File.swift
//  
//
//  Created by Brian Anglin on 3/2/21.
//
import UIKit
import Foundation

internal class UGCImageLayerBuilder: UGCLayerBuilder
{
    internal static func build(configuration: UGCImageLayerConfiguration, scene: UGCSecneRenderer) throws
    {
        let imageLayer = CALayer()
        
        guard let bgImage = UIImage(contentsOfFile: configuration.url.path) else {
            throw UGCError.imageError(message: "Unable to load image from: \(configuration.url)")
        }
        
        var attributes = configuration.format.attributes
        attributes.append(.contents( bgImage.cgImage as Any ))
        imageLayer.applyAttributes(layerAttributes: attributes)
        
        scene.outputLayer.addSublayer(imageLayer)
    }
        
    static func buildPresentation(configuration: UGCImageLayerConfiguration, presentation: UGCScenePresentation) throws
    {
        let imageLayer = CALayer()
        
        guard let bgImage = UIImage(contentsOfFile: configuration.url.path) else {
            throw UGCError.imageError(message: "Unable to load image from: \(configuration.url)")
        }
        
        var attributes = configuration.format.attributes
        attributes.append(.contents( bgImage.cgImage as Any ))
        imageLayer.applyAttributes(layerAttributes: attributes)
        
        presentation.view.layer.addSublayer(imageLayer)
    }
}
