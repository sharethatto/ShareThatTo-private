//
//  File.swift
//  
//
//  Created by Brian Anglin on 3/2/21.
//
import UIKit
import Foundation

class UGCImageLayerBuilder: UGCLayerBuilder
{
    public static func build(configuration: UGCImageLayerConfiguration, scene: UGCSecne)
    {
        let imageLayer = UGCImageLayer()
        
        guard let bgImage = UIImage(contentsOfFile: configuration.url.path) else {
            scene.status = .failed
            Logger.log(message: "Unable to load image or Layer into scene.  Failing scene.  Is the path correct?")
            return
        }
        
        if(scene.status != .failed) {
            var attributes = configuration.format.attributes
            attributes.append(.contents( bgImage.cgImage as Any ))
            imageLayer.applyAttributes(layerAttributes: attributes)
            if (imageLayer.defaultPlacements == true){
                imageLayer.transformToExpectedLayerPlacement(
                    outputLayerSize: scene.outputLayer.frame.size
                )
            }
            imageLayer.borderWidth = 4
            imageLayer.borderColor = UIColor.red.cgColor
            scene.outputLayer.addSublayer(imageLayer)
        }
    }
}
