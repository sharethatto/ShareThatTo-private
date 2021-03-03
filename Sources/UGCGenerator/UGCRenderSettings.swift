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
    
    internal var size: CGSize
    internal var fps: Int32
    internal var avCodecKey: AVVideoCodecType
    internal var filenameExt: String
    internal var assetHeight: Double
    internal var assetWidth: Double
    internal var outputFileType: AVFileType
    
    public init(renderPreset: UGCRenderPreset){
        switch renderPreset {
            case .defaultVideoAsset:
                assetHeight = 920
                assetWidth = 517.5
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
    }
    
    public enum UGCRenderPreset {
        case defaultVideoAsset
    }
}

