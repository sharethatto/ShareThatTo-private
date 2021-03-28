//
//  File.swift
//  
//
//  Created by Brian Anglin on 3/27/21.
//

import Foundation

class SafeReintrantCallbackLoader<Identifier, LoadedResult>
{
    func fetch(identifier: Identifier, completion: @escaping (LoadedResult) -> Void)
    {
        fatalError("No method implemented for loading")
    }
}

internal class SafeReintrantCallback<Identifier, Loaded>
{
    typealias LoadResult = Result<Loaded, Swift.Error>
    typealias LoadResultCompletion = (LoadResult) -> Void
    
    private let queue: DispatchQueue
    private let identifier: Identifier
    public var loader: SafeReintrantCallbackLoader<Identifier, LoadResult>?
    public init(identifier: Identifier,  queueName: String = "SafeReintrantCallback")
    {
        self.identifier = identifier
        self.queue = .init(label: "ResourceResolutionQueue")
    }
    
    private var fetchStarted: Bool = false
    private var fetchResult: LoadResult?
    private var completions: [LoadResultCompletion] = []
    
    public func fetch(completion: LoadResultCompletion? = nil)
    {
        // Every mutating call happens in the queue
        queue.async { [weak self] in
            self?.performFetch(completion: completion)
        }
    }
    
    private func performFetch(completion:  LoadResultCompletion?)
    {
        
        // If we've already gotten the result, just return the cached result
        if let result = fetchResult
        {
            completion?(result)
            return
        }
    
        // Otherwise, we're going to add it to the waiters
        if let completion = completion
        {
            completions.append(completion)
        }
        
        // Only proceed to make the request once
        guard fetchStarted == false else {
            return
        }
        fetchStarted =  true
    
        guard let loader = self.loader else {
            completion?(.failure(NSError(domain: "sharethatto", code: 1, userInfo: nil)))
            return
        }
        
        // Actually load the resource
        loader.fetch(identifier: self.identifier) {
 
            [weak self] (result) in
            // Again run the result in the queue
            self?.queue.async {
                self?.didComplete(result: result)
            }
        }
    }
    
    // Called once we've gotten a result back
    private func didComplete(result: LoadResult)
    {
        fetchResult = result
        let currentCompletions = completions
        completions = []
        
        currentCompletions.forEach{ $0(result) }
    }
}
