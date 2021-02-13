//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/3/21.
//

import AVKit
import Foundation

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


class VideoContent: Content
{
    // Providers
    private let datastore: ApplicationDatastoreProtocol
    
    // Content
    let contentType: ContentType = .video
    
    internal let title: String
    internal let videoURL: URL

    // How can we share?
    private var rawShareStrategy: RawShareStrategy
    public var renderedShareStrategy: RenderedShareStrategy?
    private var linkPreviewShareStrategy: LinkPreviewShareStrategy?
    
    // How confident do we need to be before we decide to use the link preview
    private let linkPreviewConfidenceRequired: LinkPreviewConfidence = .succeeded
    private var linkPreviewShareStrategyConfidence: LinkPreviewConfidence  = .none
    
    
    init(videoURL: URL, title: String, providers: VideoContentProviders = VideoContentProviders()) throws
    {
        self.datastore = providers.datastore
        self.videoURL = videoURL
        do {
            let video = try Data(contentsOf: videoURL, options: .mappedIfSafe)
            self.title = title
            self.rawShareStrategy = RawShareStrategy(data: video)
            
            // Start uploading
            ShareManagerVideo.init(videoContent: self, delegate: self, providers: providers.videoManagerProviders).begin()
        } catch let error {
           throw error
        }
    }

//MARK: Strategies
    
    public func rawStrategy(caller: ShareOutletProtocol?) -> ShareStretegyTypeRawProtocol
    {
        return rawShareStrategy
    }
    
    public func linkPreviewStrategy(caller: ShareOutletProtocol) -> ShareStretegyTypeLinkPreviewProtocol?
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
