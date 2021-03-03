//
//  UGCLayers.swift
//  UCGCreator
//
//  Created by Brian Anglin on 2/12/21.
//

import Foundation
import AVFoundation
import UIKit

public protocol UGCLayer : CALayer {
    func applyAttributes(layerAttributes: [CALayer.MutableLayerAttribute])
    func applyAttribute(layerAttribute: CALayer.MutableLayerAttribute)
}





public extension CALayer {
    enum MutableLayerAttribute {
        // position (normally CGPoint) and frame (normally CGRect) can be of type any to allow for special setting
        case contents(Any),  contentsRect(CGRect), contentsCenter(CGRect), contentsGravity(CALayerContentsGravity), opacity(Float), isHidden(Bool),
             masksToBounds(Bool), mask(CALayer), isDoubleSided(Bool), cornerRadius(CGFloat), maskedCorners(CACornerMask),
             borderColor(CGColor), backgroundColor(CGColor), shadowOpacity(Float), shadowRadius(CGFloat), shadowOffset(CGSize), shadowColor(CGColor),
             shadowPath(CGPath), style([AnyHashable: Any]), allowsEdgeAntialiasing(Bool), allowsGroupOpacity(Bool), filters([Any]),
             minificationFilterBias(Float), magnificationFilter(CALayerContentsFilter),isOpaque(Bool),
             edgeAntialiasingMask(CAEdgeAntialiasingMask), isGeometryFlipped(Bool), drawsAsynchronously(Bool), shouldRasterize(Bool),
             rasterizationScale(CGFloat), contentsFormat(CALayerContentsFormat), frame(CGRect), bounds(CGRect), position(CGPoint), zPosition(CGFloat),
             anchorPointZ(CGFloat), anchorPoint(CGPoint), contentsScale(CGFloat), transform(CATransform3D), sublayerTransform(CATransform3D),
             sublayers([CALayer]), actions([String : CAAction]), name(String), cornerCurve(CALayerCornerCurve),
             // Only Attributes for CATextLayer
             isWrapped(Bool), alignmentMode(CATextLayerAlignmentMode), truncationMode(CATextLayerTruncationMode), string(Any), font(CFTypeRef),
             fontSize(CGFloat), foregroundColor(CGColor), allowsFontSubpixelQuantization(Bool),
             // Share that attributes
             defaultPlacements(Bool)
             
    }
}
