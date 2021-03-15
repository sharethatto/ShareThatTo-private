//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/3/21.
//

import AVKit
import Foundation
import ShareThatToCore

class VideoContentProviders
{
    let datastore: ApplicationDatastoreProtocol
    let videoManagerProviders: ShareManagerProviders
    public init(
        datastore: ApplicationDatastoreProtocol = Datastore.shared.applicationDatastore,
        videoManagerProviders: ShareManagerProviders = ShareManagerProviders.init()
    ) {
        self.datastore = datastore
        self.videoManagerProviders = videoManagerProviders
    }
}

// Content Future?


internal typealias VideoContentResult = Result<VideoContent, Swift.Error>
internal typealias VideoContentCompletion = (VideoContentResult) -> Void



internal class VideoContentFuture
{
    private var completions: [VideoContentCompletion] = []
    private var videoContentResult: VideoContentResult? = nil
    
    
    internal init(futureProvider: VideoContentFutureProvider, title: String, providers: VideoContentProviders = VideoContentProviders(), completion:  VideoContentCompletion?)
    {
        // Add to the completions
        if let completion = completion {
            completions.append(completion)
        }
        
        futureProvider.renderingComplete() { (result) in
            switch(result) {
            case .success(let success):
                do {
                    let videoContent = try VideoContent(videoURL: success.displayURL, title: title, providers: providers)
                    self.videoContentComplete(result: .success(videoContent))
                } catch let error {
                    self.videoContentComplete(result: .failure(error))
                }
            case .failure(let error):
                self.videoContentComplete(result: .failure(error))
            }
        }
    }
    
    
    internal func addCompletion(completion: @escaping VideoContentCompletion)
    {
        if let result = videoContentResult {
            completion(result)
            return
        }
        
        completions.append(completion)
    }
    
    
    private func videoContentComplete(result: VideoContentResult)
    {
        for completion in completions
        {
            completion(result)
        }
    }
}

public class VideoContent: Content
{
    // Providers
    private let datastore: ApplicationDatastoreProtocol
    
    // Content
    public let contentType: ContentType = .video
    
    public let title: String
    public let videoURL: URL

    // How can we share?
    private var rawShareStrategy: RawShareStrategyProtocol
    internal var renderedShareStrategy: RenderedShareStrategy?
    private var linkPreviewShareStrategy: LinkPreviewShareStrategyProtocol?
    
    // How confident do we need to be before we decide to use the link preview
    private let linkPreviewConfidenceRequired: LinkPreviewConfidence = .succeeded
    private var linkPreviewShareStrategyConfidence: LinkPreviewConfidence  = .none
    
    // Hack to be abel to initialize ShareManagerVideo and use self
    private var _shareManager: ShareManagerVideo?
    var shareManager: ShareManagerVideo? {
        return _shareManager
    }

    
    init(videoURL: URL, title: String, providers: VideoContentProviders = VideoContentProviders()) throws
    {
        self.datastore = providers.datastore
        self.videoURL = videoURL
        do {
            let video = try Data(contentsOf: videoURL, options: .mappedIfSafe)
            self.title = title
            self.rawShareStrategy = RawShareStrategy(data: video)
            
            // Start uploading
            self._shareManager = ShareManagerVideo.init(videoContent: self, delegate: self, providers: providers.videoManagerProviders)
            self.shareManager?.begin()
        } catch let error {
           throw error
        }
    }

//MARK: Strategies
    
    public func rawStrategy(caller: ShareOutletProtocol?) -> RawShareStrategyProtocol
    {
        return rawShareStrategy
    }
    
    public func linkPreviewStrategy(caller: ShareOutletProtocol) -> LinkPreviewShareStrategyProtocol?
    {
        if (!linkPreviewAvailable())
        {
            return nil
        }
        return linkPreviewShareStrategy
    }
    
    // See if we're able to do link preview
    // Only allow if our confidence is greater than what is required
    public func linkPreviewAvailable() -> Bool
    {
        if (linkPreviewShareStrategy == nil) {
            return false
        }
        return linkPreviewShareStrategyConfidence >= linkPreviewConfidenceRequired
    }
    
//MARK: ShareManager
    public func cleanupContent(with usedStrategies:[ShareStretegyType])
    {
        shareManager?.cleanupContent(with:usedStrategies)
    }
    
    
//MARK: Content

    func text() -> String
    {
        // If we've decided to allow link previews
        if linkPreviewAvailable()
        {
            return title + " " + (linkPreviewShareStrategy?.link ?? "")
        }
        return title
    }
    
    func ctaLink() -> URL?
    {
        guard let application = datastore.application else { return nil }
        return URL(string: application.cta_link ?? "")
    }
    

}
    
// MARK: ShareManagerVideoDelegate

extension VideoContent: ShareManagerVideoDelegate
{
    func renderedStrategyDidUpdate(renderedStrategy: RenderedShareStrategy)
    {
        self.renderedShareStrategy = renderedStrategy
    }
    
    func linkPreviewStrategyDidUpdate(linkPreviewStrategy: LinkPreviewShareStrategy)
    {
        self.linkPreviewShareStrategy = linkPreviewStrategy
    }
    
    func linkPreviewConfidenceDidUpdate(linkPreviewConfidence: LinkPreviewConfidence)
    {
        self.linkPreviewShareStrategyConfidence = linkPreviewConfidence
    }
    
    func shareManagerDidComplete(error: Error?)
    {
        if (error != nil)
        {
            linkPreviewShareStrategyConfidence = .none
        }
    }
}
