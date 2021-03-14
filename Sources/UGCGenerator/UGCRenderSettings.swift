//
//  BaseVideoSettings.swift
//  video_generator
//
//  Created by Brian Anglin on 2/8/21.
//
import UIKit
import Foundation
import AVFoundation


public struct UGCRenderSettings {
    
    public static var defaultVideoAsset: UGCRenderSettings {
        get {  UGCRenderSettings(renderPreset: .defaultVideoAsset) }
    }
    
    // Video Render Settings
    public let size: CGSize
    internal let fps: Int32
    internal let avCodecKey: AVVideoCodecType
    internal let filenameExt: String
    internal let assetHeight: Double
    internal let assetWidth: Double
    internal let outputFileType: AVFileType
    
    // Composition options
    internal var backgroundColor: CGColor = UIColor.white.cgColor
    
    public init(renderPreset: UGCRenderPreset, renderOptions: [UGCRenderOptions] = []){
        switch renderPreset {
            case .defaultVideoAsset:
                assetHeight = 960
                assetWidth = 540
                size = CGSize(width: assetWidth, height: assetHeight)
                fps = 30
                if #available(iOS 11.0, *) {
                    avCodecKey = AVVideoCodecType.h264
                } else {
                    avCodecKey = AVVideoCodecType(rawValue: AVVideoCodecH264)
                }
                filenameExt = "mp4"
                outputFileType = AVFileType.mp4
        }
        for option in renderOptions {
            switch option {
            case .backgroundColor(let color):
                backgroundColor = color
            }
        }
    }
    
    public enum UGCRenderPreset {
        case defaultVideoAsset
    }
    
    public enum UGCRenderOptions {
        case backgroundColor(CGColor)
    }
}

