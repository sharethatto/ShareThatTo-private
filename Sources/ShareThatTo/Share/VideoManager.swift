//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/9/21.
//

import Foundation


class ShareManagerProviders {
    let render: RenderProtocol
    let uploadNetwork: NetworkUploadProtocol
    let shareNetwork: NetworkShareProtocol
    public init(
        shareNetwork: NetworkShareProtocol = Network.shared,
        uploadNetwork: NetworkUploadProtocol = Network.shared,
        render: RenderProtocol = Render.init()
    ) {
        self.uploadNetwork = uploadNetwork
        self.shareNetwork = shareNetwork
        self.render = render
    }
}

protocol ShareManagerVideoDelegate
{
    func renderedStrategyDidUpdate(renderedStrategy: RenderedShareStrategy)
    func linkPreviewStrategyDidUpdate(linkPreviewStrategy: LinkPreviewShareStrategy)
    func linkPreviewConfidenceDidUpdate(linkPreviewConfidence: LinkPreviewConfidence)
    func shareManagerDidComplete(error: Swift.Error?)
}

extension ShareManagerVideo
{
    enum Error: LocalizedError
    {
        case unknown
        case destoryed
        var errorDescription: String? {
            switch self
            {
            case .unknown: return NSLocalizedString("An unknown error occurred.", comment: "")
            case .destoryed: return NSLocalizedString("Resource was destroyed.", comment: "")
            }
        }
    }
}


class ShareManagerVideo
{
 
    private let delegate: ShareManagerVideoDelegate?
    private let providers: ShareManagerProviders
    private let videoContent: VideoContent
    
    // This is a way to stop and clean up after ourselves
    private var destroyed: Bool = false
    
    public init(videoContent: VideoContent, delegate: ShareManagerVideoDelegate?, providers: ShareManagerProviders = ShareManagerProviders())
    {
        self.providers = providers
        self.videoContent = videoContent
        self.delegate = delegate
    }
    
    public func begin()
    {
        render()
    }
    
    public func cleanupContent(with usedStrategies:[ShareStretegyType])
    {
        if (!usedStrategies.contains(.linkPreview))
        {
            destroy()
        }
    }
    
    private func destroy()
    {
        self.destroyed = true
        guard let shareable = self.shareable else {
            
            self.delegate?.shareManagerDidComplete(error: Error.destoryed)
            return
        }
        
        providers.shareNetwork.deleteShare(delete: DeleteShareRequest(shareable_access_token: shareable.shareable_access_token)) { (result) in
            switch(result) {
                case .failure(let error):
                    Logger.shareThatToDebug(string: "[VideoManager destroy] failure", error: error)
                    self.delegate?.shareManagerDidComplete(error: error)
                case .success:
                    Logger.shareThatToDebug(string: "[VideoManager destroy] success")
                    self.delegate?.shareManagerDidComplete(error: Error.destoryed)
            }
        }
    }
    
    // Steps
    // Render -> SharePlan -> 2x ( Upload -> Activate )

    private var thumbnail: Data?
    private var renderedVideo: Data?
    
    private func render()
    {
        providers.render.renderThumbnailAndVideo(videoURL: videoContent.videoURL) { (result) in
            switch(result) {
            case .failure(let error):
                Logger.shareThatToDebug(string: "[VideoManager render] failure", error: error)
                self.delegate?.shareManagerDidComplete(error: error)
            case .success(let datas):
                Logger.shareThatToDebug(string: "[VideoManager render] success")
                self.thumbnail = datas.0
                self.renderedVideo = datas.1
                self.delegate?.renderedStrategyDidUpdate(renderedStrategy: RenderedShareStrategy(data: datas.1))
                self.uploadPlan()
            }
        }
    }
    
    private var shareable: Shareable?
    
    enum UploadKey: String {
        case previewImage = "preview_image"
        case videoContent = "video_content"
    }
    
    private func uploadPlan()
    {
        if (self.destroyed) {
            return
        }
        
        guard let renderedVideo = self.renderedVideo else { self.delegate?.shareManagerDidComplete(error: Error.unknown); return }
        guard let thumbnail = self.thumbnail else { self.delegate?.shareManagerDidComplete(error: Error.unknown); return }
        let shareableRequest = ShareableRequest(title: self.videoContent.title, shareable_type: "video")
        let shareRequest = ShareRequest(video_content: renderedVideo.uploadPlan(contentType: "video/mp4"),
                                        preview_image: thumbnail.uploadPlan(contentType: "image/jpeg"),
                                        shareable: shareableRequest)
        providers.shareNetwork.shareRequest(share: shareRequest) { (result) in
            switch(result) {
            case .failure(let error):
                Logger.shareThatToDebug(string: "[VideoManager uploadPlan] failure", error: error)
                self.delegate?.shareManagerDidComplete(error: error)
            case .success(let result):
                self.shareable = result.shareable
                // We've just created it but we're going to delete it here if destroyed has been set
                if (self.destroyed) {
                    guard let token = self.shareable?.shareable_access_token else { return }
                    self.providers.shareNetwork.deleteShare(delete: DeleteShareRequest(shareable_access_token: token )){ _ in 
                        if (1 == 2) {}
                    }
                    return
                }
                
                self.delegate?.linkPreviewStrategyDidUpdate(linkPreviewStrategy: LinkPreviewShareStrategy(link: result.shareable.link))
                self.delegate?.linkPreviewConfidenceDidUpdate(linkPreviewConfidence: .planReceived)
                Logger.shareThatToDebug(string: "[VideoManager uploadPlan] success")
                self.upload(with: result.preview_image, data: thumbnail, uploadKey: .previewImage)
                self.upload(with: result.video_content, data: renderedVideo, uploadKey: .videoContent)
            }
        }
    }

    
    private func upload(with plan:UploadPlan, data: Data, uploadKey: UploadKey)
    {
        if (self.destroyed) {
            return
        }
        providers.uploadNetwork.upload(plan: plan, data: data) { (result) in
            switch(result) {
            case .failure(let error):
                Logger.shareThatToDebug(string: "[VideoManager upload] failure \(uploadKey)", error: error)
                self.delegate?.shareManagerDidComplete(error: error)
            case .success():
                Logger.shareThatToDebug(string: "[VideoManager upload] success \(uploadKey)")
                self.activate(uploadKey: uploadKey)
            }
        }
    }
    
    private var previewImageCompleted = false
    private var videoContentCompleted = false
    
    private func activate(uploadKey: UploadKey)
    {
        if (self.destroyed) {
            return
        }
        guard  let shareable = shareable else {
            self.delegate?.shareManagerDidComplete(error: Error.unknown)
            return
        }
        let activateShareRequest = ActivateRequest(
            video_content: uploadKey == .videoContent,
            preview_image: uploadKey == .previewImage,
            shareable_access_token: shareable.shareable_access_token)
        providers.shareNetwork.activateShare(activate: activateShareRequest) {
            (result) in
            switch(result) {
            case .failure(let error):
                Logger.shareThatToDebug(string: "[VideoManager activate] failure \(uploadKey)", error: error)
                self.delegate?.shareManagerDidComplete(error: error)
            case .success:
                Logger.shareThatToDebug(string: "[VideoManager activate] success \(uploadKey)")
                switch(uploadKey) {
                case .previewImage: self.previewImageCompleted = true
                case .videoContent: self.videoContentCompleted = true
                }
                if (self.previewImageCompleted && self.videoContentCompleted) {
                    self.delegate?.linkPreviewConfidenceDidUpdate(linkPreviewConfidence: .succeeded)
                    self.delegate?.shareManagerDidComplete(error: nil)
                }
            }
        }
    }
}
