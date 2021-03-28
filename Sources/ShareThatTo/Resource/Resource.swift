//
//  File.swift
//  
//
//  Created by Brian Anglin on 3/27/21.
//

import Foundation


internal typealias FetchIdentifier = URL
internal typealias FetchValue = URL
internal typealias FetchResult = Result<URL, Swift.Error>
internal typealias FetchResultCompletion = (FetchResult) -> Void

//// Handle safe re-entry & thread safety so the resouce is only loaded once

internal class ResourceHelper: SafeReintrantCallbackLoader<FetchIdentifier, FetchResult>
{
    override func fetch(identifier: FetchIdentifier, completion: @escaping FetchResultCompletion)
    {
        if (identifier.isFileURL)
        {
            return completion(.success(identifier))
        }
        ResourceLoader.shared.fetch(url: identifier, completion: completion)
    }
}

internal class Resource: SafeReintrantCallback<FetchIdentifier, FetchValue>
{
    public init(identifier: FetchIdentifier)
    {
        super.init(identifier: identifier)
        self.loader = ResourceHelper()
    }
}
