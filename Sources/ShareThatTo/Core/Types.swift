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



public protocol VideoContentFutureProvider
{
    func renderingComplete(completion: @escaping RenderingResultCompletion)
    func startRendering()
}

public protocol TitleProvider {
    var title: String? { get }
}

public typealias ContentProvider = (Presentable & VideoContentFutureProvider & TitleProvider)

public typealias NilSuccessCompletion = (Swift.Error?) -> Void



public enum PresentationResult {
    case cancelled
    case shared(destination: String)
}

public typealias SharePresentationCompletion = (PresentationResult) -> Void
