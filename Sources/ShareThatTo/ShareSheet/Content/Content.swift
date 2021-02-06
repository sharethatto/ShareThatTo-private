//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/3/21.
//

import Foundation

enum ContentType {
    case unknown
    case video
}

enum ContentPreparation {
    case notStarted
    case failed
    case succeeded
}

protocol Content {
    var contentType: ContentType { get }
    var contentPreparation: ContentPreparation { get }
}
