//
//  UGCLayers.swift
//  UCGCreator
//
//  Created by Brian Anglin on 2/12/21.
//

import Foundation
import AVFoundation
import UIKit

public extension CALayer {
    enum MutableLayerAttributeCodingKeys: CodingKey
    {
        case contents
        case contentsRect
        case contentsCenter
        case contentsGravity
        case opacity
        case isHidden
        case masksToBounds
        case mask
        case isDoubleSided
        case cornerRadius
        case maskedCorners
        case borderColor
        case borderWidth
        case backgroundColor
        case shadowOpacity
        case shadowRadius
        case shadowOffset
        case shadowColor
        case shadowPath
        case style
        case allowsEdgeAntialiasing
        case allowsGroupOpacity
        case filters
        case minificationFilterBias
        case magnificationFilter
        case edgeAntialiasingMask
        case isGeometryFlipped
        case drawsAsynchronously
        case shouldRasterize
        case rasterizationScale
        case contentsFormat
        case frame
        case bounds
        case position
        case zPosition
        case anchorPointZ
        case anchorPoint
        case contentsScale
        case transform
        case sublayerTransform
        case sublayers
        case actions
        case name
        case cornerCurve
        case isWrapped
        case alignmentMode
        case truncationMode
        case string
        case font
        case fontSize
        case foregroundColor
        case allowsFontSubpixelQuantization
    }
    enum MutableLayerAttribute {
        // position (normally CGPoint) and frame (normally CGRect) can be of type any to allow for special setting
        case contents(Any),  contentsRect(CGRect), contentsCenter(CGRect), contentsGravity(CALayerContentsGravity), opacity(Float), isHidden(Bool),
             masksToBounds(Bool), mask(CALayer), isDoubleSided(Bool), cornerRadius(CGFloat), maskedCorners(CACornerMask),
             borderColor(CGColor), borderWidth(CGFloat), backgroundColor(CGColor), shadowOpacity(Float), shadowRadius(CGFloat), shadowOffset(CGSize), shadowColor(CGColor),
             shadowPath(CGPath), style([AnyHashable: Any]), allowsEdgeAntialiasing(Bool), allowsGroupOpacity(Bool), filters([Any]),
             minificationFilterBias(Float), magnificationFilter(CALayerContentsFilter),isOpaque(Bool),
             edgeAntialiasingMask(CAEdgeAntialiasingMask), isGeometryFlipped(Bool), drawsAsynchronously(Bool), shouldRasterize(Bool),
             rasterizationScale(CGFloat), contentsFormat(CALayerContentsFormat), frame(CGRect), bounds(CGRect), position(CGPoint), zPosition(CGFloat),
             anchorPointZ(CGFloat), anchorPoint(CGPoint), contentsScale(CGFloat), transform(CATransform3D), sublayerTransform(CATransform3D),
             sublayers([CALayer]), actions([String : CAAction]), name(String), cornerCurve(CALayerCornerCurve),
             // Only Attributes for CATextLayer
             isWrapped(Bool), alignmentMode(CATextLayerAlignmentMode), truncationMode(CATextLayerTruncationMode), string(Any), font(CFTypeRef),
             fontSize(CGFloat), foregroundColor(CGColor), allowsFontSubpixelQuantization(Bool)
    }
    
    func applyAttributes(layerAttributes: [CALayer.MutableLayerAttribute])
    {
        for layerAttribute in layerAttributes{
            switch layerAttribute{
            case .contents(let value):
                self.contents = value
            case .contentsRect(let value):
                self.contentsRect = value
            case .contentsCenter(let value):
                self.contentsCenter = value
            case .contentsGravity(let value):
                self.contentsGravity = value
            case .opacity(let value):
                self.opacity = value
            case .isHidden(let value):
                self.isHidden = value
            case .masksToBounds(let value):
                self.masksToBounds = value
            case .mask(let value):
                self.mask = value
            case .isDoubleSided(let value):
                self.isDoubleSided = value
            case .cornerRadius(let value):
                self.cornerRadius = value
            case .maskedCorners(let value):
                if #available(iOS 11.0, *) {
                    self.maskedCorners = value
                } else {
                    // Fallback on earlier versions
                }
            case .borderColor(let value):
                self.borderColor = value
            case .borderWidth(let value):
                self.borderWidth = value
            case .backgroundColor(let value):
                self.backgroundColor = value
            case .shadowOpacity(let value):
                self.shadowOpacity = value
            case .shadowRadius(let value):
                self.shadowRadius = value
            case .shadowOffset(let value):
                self.shadowOffset = value
            case .shadowColor(let value):
                self.shadowColor = value
            case .shadowPath(let value):
                self.shadowPath = value
            case .style(let value):
                self.style = value
            case .allowsEdgeAntialiasing(let value):
                self.allowsEdgeAntialiasing = value
            case .allowsGroupOpacity(let value):
                self.allowsGroupOpacity = value
            case .filters(let value):
                self.filters = value
            case .minificationFilterBias(let value):
                self.minificationFilterBias = value
            case .magnificationFilter(let value):
                self.magnificationFilter = value
            case .isOpaque(let value):
                self.isOpaque = value
            case .edgeAntialiasingMask(let value):
                self.edgeAntialiasingMask = value
            case .isGeometryFlipped(let value):
                self.isGeometryFlipped = value
            case .drawsAsynchronously(let value):
                self.drawsAsynchronously = value
            case .shouldRasterize(let value):
                self.shouldRasterize = value
            case .rasterizationScale(let value):
                self.rasterizationScale = value
            case .contentsFormat(let value):
                self.contentsFormat = value
            case .frame(let value):
                self.frame = value
            case .bounds(let value):
                self.bounds = value
            case .position(let value):
                self.position = value
            case .zPosition(let value):
                self.zPosition = value
            case .anchorPointZ(let value):
                self.anchorPointZ = value
            case .anchorPoint(let value):
                self.anchorPoint = value
            case .contentsScale(let value):
                self.contentsScale = value
            case .transform(let value):
                self.transform = value
            case .sublayerTransform(let value):
                self.sublayerTransform = value
            case .sublayers(let value):
                self.sublayers = value
            case .actions(let value):
                self.actions = value
            case .name(let value):
                self.name = value
            case .cornerCurve(let value):
                if #available(iOS 13.0, *) {
                    self.cornerCurve = value
                } else {
                    // Fallback on earlier versions
                }
            default:
                if let textLayer = self as? CATextLayer
                {
                    switch layerAttribute{
                        case .isWrapped(let value):
                            textLayer.isWrapped = value
                        case .alignmentMode(let value):
                            textLayer.alignmentMode = value
                        case .truncationMode(let value):
                            textLayer.truncationMode = value
                        case .string(let value):
                            textLayer.string = value
                        case .font(let value):
                            textLayer.font = value
                        case .fontSize(let value):
                            textLayer.fontSize = value
                        case .foregroundColor(let value):
                            textLayer.foregroundColor = value
                        case .allowsFontSubpixelQuantization(let value):
                            textLayer.allowsFontSubpixelQuantization = value
                        default:
                            UGCLogger.log(message: "This Layer attribute does not exist for this layer type.  Ignoring attribute, but preceding creating layer. layerAttribute \(layerAttribute)")
                    }
                }
                else
                {
                    UGCLogger.log(message: "This Layer attribute does not exist for this layer type.  Ignoring attribute, but preceding creating layer. layerAttribute \(layerAttribute)")
                }
            }
        }
    }
    
    func applyAttribute(layerAttribute: CALayer.MutableLayerAttribute)
    {
        applyAttributes(layerAttributes: [layerAttribute])
    }
}




internal extension CALayer
{
    func transformToExpectedAssetScale(outputLayerSize: CGSize, assetSize: CGSize) -> CGAffineTransform
    {
        
        let scaleToFitRatio: CGFloat
        if (assetSize.width >= assetSize.height){
            scaleToFitRatio = self.frame.width / assetSize.width
        } else {
            scaleToFitRatio = self.frame.height / assetSize.height
        }
        
        let scaleFactor = CGAffineTransform(
            scaleX: scaleToFitRatio * CGFloat(outputLayerSize.width / self.frame.width) ,
            y:  scaleToFitRatio * CGFloat(outputLayerSize.height / self.frame.height)
        )
        
        return scaleFactor
    }
}
