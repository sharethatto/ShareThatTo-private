//
//  File.swift
//  
//
//  Created by Brian Anglin on 3/2/21.
//


import Foundation
import ShareThatToCore

public enum UGCError: Error
{
    case unknown
    case noDuration
    case exportFailedOrCancelled
    case exportFailedFatally
    case videoError(message: String)
    case imageError(message: String)
    
    var retryable: Bool {
        switch self {
        // This happen when the app is backgrounded so we can retry
        case .exportFailedOrCancelled: return true
        case .exportFailedFatally: return true
        default: return false
        }
    }
    var errorDescription: String {
        switch self {
        case .exportFailedOrCancelled: return NSLocalizedString("Export failed or cancelled", comment: "")
        case .noDuration: return NSLocalizedString("No duration set", comment: "")
        case .exportFailedFatally: return NSLocalizedString("Export failed fatally", comment: "")
        case .imageError(let message):
            return NSLocalizedString("Image error: \(message)", comment: "")
        case .videoError(let message):
            return NSLocalizedString("Video error: \(message)", comment: "")
        default: return NSLocalizedString("Unknown configuraiton error", comment: "")
        }
    }
}


public typealias UGCResult = Result<SuccessfulRenderingResult, UGCError>

public typealias UGCSuccessResult = SuccessfulRenderingResult

public typealias UGCResultCompletion = (UGCResult) -> Void

public protocol UGCResultDelegate: class
{
    func didFinish(result: UGCResult)
}

public typealias UGCPresentationCompletion = () -> Void
