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

public class UGCVideoLayer : CALayer, UGCLayer {
    
    var defaultPlacements: Bool = false
    
    public override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func transformToExpectedLayerPlacement(outputLayerSize: CGSize, assetSize: CGSize) {
        var aspectRatioForMinDimension: CGFloat

        if (assetSize.width >= assetSize.height){
            aspectRatioForMinDimension = (assetSize.height / assetSize.width)
        } else {
            aspectRatioForMinDimension = (assetSize.width / assetSize.height)
        }
        
        let userInputFrame = self.frame
        
        let newGeneratedWidth = (assetSize.width >= assetSize.height) ? userInputFrame.width : (aspectRatioForMinDimension * userInputFrame.height)
        let newGeneratedHeight = (assetSize.width >= assetSize.height) ? (aspectRatioForMinDimension * userInputFrame.width) : userInputFrame.height
        
        self.frame = CGRect(
            x: userInputFrame.minX,
            y: (outputLayerSize.height - userInputFrame.minY - newGeneratedHeight),
            width: newGeneratedWidth,
            height: newGeneratedHeight
        )
    }
    
    static func transformToExpectedAssetScale(outputLayerSize: CGSize, outputFrameSize: CGSize, assetSize: CGSize) -> CGAffineTransform{
        
        let scaleToFitRatio: CGFloat
        if (assetSize.width >= assetSize.height){
            scaleToFitRatio = outputFrameSize.width / assetSize.width
        } else {
            scaleToFitRatio = outputFrameSize.height / assetSize.height
        }
        
        let scaleFactor = CGAffineTransform(
            scaleX: scaleToFitRatio * CGFloat(outputLayerSize.width / outputFrameSize.width) ,
            y:  scaleToFitRatio * CGFloat(outputLayerSize.height / outputFrameSize.height)
        )
        
        return scaleFactor
    }
    
    public func applyAttribute(layerAttribute: CALayer.MutableLayerAttribute){
        self.applyAttributes(layerAttributes: [layerAttribute])
    }
    
    public func applyAttributes(layerAttributes: [CALayer.MutableLayerAttribute]){
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
            case .defaultPlacements(let value):
                self.defaultPlacements = value
            default:
                Logger.log(message: "This Layer attribute does not exist for this layer type.  Ignoring attribute, but preceding creating layer. layerAttribute \(layerAttribute)")
            }
        }
    }
}

public class UGCImageLayer : CALayer, UGCLayer {
    
    var defaultPlacements: Bool = false
    
    public override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func transformToExpectedLayerPlacement(outputLayerSize: CGSize) {
        
        let userInputFrame = self.frame
        
        self.frame = CGRect(
            x: userInputFrame.minX,
            y: (outputLayerSize.height - userInputFrame.minY - userInputFrame.height),
            width: userInputFrame.width,
            height: userInputFrame.height
        )
    }

    
    func transformToExpectedAssetScale(outputLayerSize: CGSize, assetSize: CGSize) {
    }
    
    public func applyAttribute(layerAttribute: CALayer.MutableLayerAttribute){
        self.applyAttributes(layerAttributes: [layerAttribute])
    }
    
    public func applyAttributes(layerAttributes: [CALayer.MutableLayerAttribute]){
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
            case .defaultPlacements(let value):
                self.defaultPlacements = value
            default:
                Logger.log(message: "This Layer attribute does not exist for this layer type.  Ignoring attribute, but preceding creating layer. layerAttribute \(layerAttribute)")
            }
        }
    }
}

public class UGCTextLayer : CATextLayer, UGCLayer {
    
    var defaultPlacements: Bool = false
    
    public override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func transformToExpectedLayerPlacement(outputLayerSize: CGSize) {
        
        let userInputFrame = self.frame
        
        self.frame = CGRect(
            x: userInputFrame.minX,
            y: (outputLayerSize.height - userInputFrame.minY - userInputFrame.height),
            width: userInputFrame.width,
            height: userInputFrame.height
        )
    }
    
    func transformToExpectedFontScale(outputLayerSize: CGSize, assetSize: CGSize) {
    }
    
    public func applyAttribute(layerAttribute: CALayer.MutableLayerAttribute){
        self.applyAttributes(layerAttributes: [layerAttribute])
    }
    
    public func applyAttributes(layerAttributes: [CALayer.MutableLayerAttribute]) {
        for layerAttribute in layerAttributes {
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
            case .defaultPlacements(let value):
                self.defaultPlacements = value
            case .isWrapped(let value):
                self.isWrapped = value
            case .alignmentMode(let value):
                self.alignmentMode = value
            case .truncationMode(let value):
                self.truncationMode = value
            case .string(let value):
                self.string = value
            case .font(let value):
                self.font = value
            case .fontSize(let value):
                self.fontSize = value
            case .foregroundColor(let value):
                self.foregroundColor = value
            case .allowsFontSubpixelQuantization(let value):
                self.allowsFontSubpixelQuantization = value
            default:
                Logger.log(message: "This Layer attribute does not exist for this layer type.  Ignoring attribute, but preceding creating layer. layerAttribute \(layerAttribute)")
            }
        }
    }

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
