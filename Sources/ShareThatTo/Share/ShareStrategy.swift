//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/7/21.
//

import Foundation

public enum ShareStrategy: Int {
    case none = 0
    case raw = 1
    case rendered = 2
    case linkPreview = 3
}

public enum ShareStretegyType
{
    case raw
    case linkPreview
}

public protocol ShareStretegyTypeRawProtocol
{
    var data: Data { get }
}

public protocol ShareStretegyTypeLinkPreviewProtocol
{
    var link: String { get }
}

public protocol ShareStrategyProtocol
{
    var shareStrategy: ShareStrategy { get }
    var shareStrategyType: ShareStretegyType { get  }
}

public class RawShareStrategy: ShareStrategyProtocol, ShareStretegyTypeRawProtocol
{
    public let shareStrategy:ShareStrategy = .raw
    public var shareStrategyType:ShareStretegyType = .raw
    public var data: Data
    
    init(data: Data)
    {
        self.data = data
    }
}

public class RenderedShareStrategy: ShareStrategyProtocol,  ShareStretegyTypeRawProtocol
{
    public let shareStrategy:ShareStrategy = .rendered
    public var shareStrategyType:ShareStretegyType = .raw
    public var data: Data
    init(data: Data)
    {
        self.data = data
    }
}

public class LinkPreviewShareStrategy: ShareStrategyProtocol, ShareStretegyTypeLinkPreviewProtocol
{
    public let shareStrategy:ShareStrategy = .linkPreview
    public var shareStrategyType:ShareStretegyType = .linkPreview
    public var link: String
    init(link: String)
    {
        self.link = link
    }
}

public enum LinkPreviewConfidence: Int, Comparable
{
    public static func < (lhs: LinkPreviewConfidence, rhs: LinkPreviewConfidence) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    case none = 0
    case planReceived = 1
    case thumbnailUploadedAndActivated = 2
    case videoUploaded = 3
    case succeeded = 5
}
