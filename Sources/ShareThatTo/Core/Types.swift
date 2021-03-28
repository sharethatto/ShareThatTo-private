//
//  File.swift
//  
//
//  Created by Brian Anglin on 3/14/21.
//

import Foundation

public struct SuccessfulRenderingResult: Equatable
{
    public let displayURL: URL
    public init(displayURL: URL)
    {
        self.displayURL = displayURL
    }
}

public typealias RenderingResult = Result<SuccessfulRenderingResult, Swift.Error>

public typealias RenderingResultCompletion = (RenderingResult) -> Void



internal protocol VideoContentFutureProvider
{
    func renderingComplete(completion: @escaping RenderingResultCompletion)
    func startRendering()
}

public protocol TitleProvider {
    var title: String? { get }
}

internal typealias ContentProvider = (Presentable & VideoContentFutureProvider & TitleProvider)

public enum PresentationResult {
    case cancelled
    case shared(destination: String)
    case ignored
}

public typealias SharePresentationCompletion = (PresentationResult) -> Void

public enum PresentationStyle {
    case shareSheet
    case toast(message: String)
}

