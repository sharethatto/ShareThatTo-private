//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/7/21.
//

import Foundation

enum ShareStrategy {
    case raw
    case rendered
    case linkPreview
}

enum ShareStretegyType
{
    case raw
    case linkPreview
}

protocol ShareStretegyTypeRawProtocol
{
    var data: Data { get }
}

protocol ShareStretegyTypeLinkPreviewProtocol
{
    var link: String { get }
}

protocol ShareStrategyProtocol
{
    var shareStrategy: ShareStrategy { get }
    var shareStrategyType: ShareStretegyType { get  }
}

class RawShareStrategy: ShareStrategyProtocol, ShareStretegyTypeRawProtocol
{
    let shareStrategy:ShareStrategy = .raw
    var shareStrategyType:ShareStretegyType = .raw
    var data: Data
    
    init(data: Data)
    {
        self.data = data
    }
}

class RenderedShareStrategy: ShareStrategyProtocol,  ShareStretegyTypeRawProtocol
{
    let shareStrategy:ShareStrategy = .rendered
    var shareStrategyType:ShareStretegyType = .raw
    var data: Data
    init(data: Data)
    {
        self.data = data
    }
}

class LinkPreviewShareStrategy: ShareStrategyProtocol, ShareStretegyTypeLinkPreviewProtocol
{
    let shareStrategy:ShareStrategy = .linkPreview
    var shareStrategyType:ShareStretegyType = .linkPreview
    var link: String
    init(link: String)
    {
        self.link = link
    }
}

enum LinkPreviewConfidence: Int, Comparable
{
    static func < (lhs: LinkPreviewConfidence, rhs: LinkPreviewConfidence) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    case none = 0
    case planReceived = 1
    case thumbnailUploadedAndActivated = 2
    case videoUploaded = 3
    case succeeded = 5
}
