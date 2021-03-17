//
//  BaseVideoSettings.swift
//  video_generator
//
//  Created by Brian Anglin on 2/8/21.
//
import UIKit
import Foundation
import AVFoundation

public enum UGCRenderPreset
{
    case verticalVideoPreset
}

public enum UGCRenderOptions
{
    case backgroundColor(CGColor)
    case preset(UGCRenderPreset)
    case width(CGFloat)
    case height(CGFloat)
}

public struct UGCRenderSettings
{
    
    // Video Render Settings
    public var size: CGSize
    internal let fps: Int32
    internal let avCodecKey: AVVideoCodecType
    internal let filenameExt: String

    internal let outputFileType: AVFileType
    
    // Composition options
    internal var backgroundColor: CGColor = UIColor.white.cgColor
    
    public init(_ options: [UGCRenderOptions] = []){
        let presets = options.compactMap { (option) -> UGCRenderPreset? in
            switch option {
            case .preset(let preset):
                return preset
            default: break
            }
            return nil
        }
        
        let preset: UGCRenderPreset = presets[safe: 0] ?? .verticalVideoPreset
        
        switch preset {
        case .verticalVideoPreset:
            size = CGSize(width: 540, height: 960)
            fps = 30
            if #available(iOS 11.0, *) {
                avCodecKey = AVVideoCodecType.h264
            } else {
                avCodecKey = AVVideoCodecType(rawValue: AVVideoCodecH264)
            }
            filenameExt = "mp4"
            outputFileType = AVFileType.mp4
        }
        
        
        for option in options
        {
            switch option {
            case .backgroundColor(let color):
                backgroundColor = color
            case .height(let height):
                size = CGSize(width: size.width, height: height)
            case .width(let width):
                size = CGSize(width: width, height: size.height)
            case .preset(_): break
            }
        }
    }
}

