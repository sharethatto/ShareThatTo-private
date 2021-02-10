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
        var errorDescription: String? {
            switch self
            {
            case .unknown: return NSLocalizedString("An unknown error occurred.", comment: "")
        
            }
        }
    }
}


class ShareManagerVideo
{
 
    private let delegate: ShareManagerVideoDelegate?
    private let providers: ShareManagerProviders
    private let videoContent: VideoContent
    
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
    
    // Steps
    // Render -> SharePlan -> 2x ( Upload -> Activate )

    private var thumbnail: Data?
    private var renderedVideo: Data?
    
    private func render()
    {
        providers.render.renderThumbnailAndVideo(videoURL: videoContent.videoURL) { (result) in
            switch(result) {
            case .failure(let error):
                self.delegate?.shareManagerDidComplete(error: error)
            case .success(let datas):
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
        guard let renderedVideo = self.renderedVideo else { self.delegate?.shareManagerDidComplete(error: Error.unknown); return }
        guard let thumbnail = self.thumbnail else { self.delegate?.shareManagerDidComplete(error: Error.unknown); return }
        let shareableRequest = ShareableRequest(title: self.videoContent.title, shareable_type: "video")
        let shareRequest = ShareRequest(video_content: renderedVideo.uploadPlan(contentType: "video/mp4"),
                                        preview_image: thumbnail.uploadPlan(contentType: "image/jpeg"),
                                        shareable: shareableRequest)
        providers.shareNetwork.shareRequest(share: shareRequest) { (result) in
            switch(result) {
            case .failure(let error):
                self.delegate?.shareManagerDidComplete(error: error)
            case .success(let result):
                self.shareable = result.shareable
                self.delegate?.linkPreviewStrategyDidUpdate(linkPreviewStrategy: LinkPreviewShareStrategy(link: result.shareable.link))
                self.delegate?.linkPreviewConfidenceDidUpdate(linkPreviewConfidence: .planReceived)
                self.upload(with: result.preview_image, data: thumbnail, uploadKey: .previewImage)
                self.upload(with: result.video_content, data: renderedVideo, uploadKey: .videoContent)
            }
        }
    }

    
    private func upload(with plan:UploadPlan, data: Data, uploadKey: UploadKey)
    {
        providers.uploadNetwork.upload(plan: plan, data: data) { (result) in
            switch(result) {
            case .failure(let error):
                self.delegate?.shareManagerDidComplete(error: error)
            case .success():
                self.activate(uploadKey: uploadKey)
            }
        }
    }
    
    private var previewImageCompleted = false
    private var videoContentCompleted = false
    
    private func activate(uploadKey: UploadKey)
    {
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
                self.delegate?.shareManagerDidComplete(error: error)
            case .success:
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