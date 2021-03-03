//
//  UGCFormat.swift
//  UCGCreator
//
//  Created by Brian Anglin on 2/14/21.
//

import Foundation
import AVKit

protocol UGCFormat {
    var attributes: [CALayer.MutableLayerAttribute] { get set }
    func appendAttribute(_ newAttribute: CALayer.MutableLayerAttribute)
}

// TODO: Make smart assumptions about anchors in UGC
public class UGCTextFormat : UGCFormat {
    let textTemplate: String
    var attributes: [CALayer.MutableLayerAttribute]
    
    public init(
        textTemplate: String,
        attributes: [CALayer.MutableLayerAttribute] ) {
        self.textTemplate = textTemplate
        self.attributes = attributes
    }
    
    public func appendAttribute(_ newAttribute: CALayer.MutableLayerAttribute){
        attributes.append(newAttribute)
    }
    
}

public class UGCVideoFormat : UGCFormat {
    public var attributes: [CALayer.MutableLayerAttribute]
    
    public init(
        attributes: [CALayer.MutableLayerAttribute] ) {
        self.attributes = attributes
    }
    
    public func appendAttribute(_ newAttribute: CALayer.MutableLayerAttribute){
        attributes.append(newAttribute)
    }
    
}


public class UGCImageFormat : UGCFormat {
    public var attributes: [CALayer.MutableLayerAttribute]
    
    public init(
        attributes: [CALayer.MutableLayerAttribute] ) {
        self.attributes = attributes
    }
    
    public func appendAttribute(_ newAttribute: CALayer.MutableLayerAttribute){
        attributes.append(newAttribute)
    }
    
}
