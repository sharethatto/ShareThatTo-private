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
        
        let image: UIImage
        if let unwrappedImage: UIImage = configuration.image {
            image = unwrappedImage
        }
        else
        {
            guard let unwrappedURL: URL = configuration.url else {
                throw UGCError.imageError(message: "No url set for image")
            }
            guard let unwrappedImage = UIImage(contentsOfFile: unwrappedURL.path) else {
                throw UGCError.imageError(message: "Unable to load image from: \(configuration.url)")
            }
            image = unwrappedImage
        }
        

        
        var attributes = configuration.format.attributes
        attributes.append(.contents( image.cgImage as Any ))
        imageLayer.applyAttributes(layerAttributes: attributes)
        
        scene.outputLayer.addSublayer(imageLayer)
    }
        
    static func buildPresentation(configuration: UGCImageLayerConfiguration, presentation: UGCScenePresentation) throws
    {
        let imageLayer = CALayer()
        
        let image: UIImage
        if let unwrappedImage: UIImage = configuration.image {
            image = unwrappedImage
        }
        else
        {
            guard let unwrappedURL: URL = configuration.url else {
                throw UGCError.imageError(message: "No url set for image")
            }
            guard let unwrappedImage = UIImage(contentsOfFile: unwrappedURL.path) else {
                throw UGCError.imageError(message: "Unable to load image from: \(configuration.url?.description ?? "")")
            }
            image = unwrappedImage
        }
        
        var attributes = configuration.format.attributes
        attributes.append(.contents( image.cgImage as Any ))
        imageLayer.applyAttributes(layerAttributes: attributes)
        
        presentation.view.layer.addSublayer(imageLayer)
    }
}
