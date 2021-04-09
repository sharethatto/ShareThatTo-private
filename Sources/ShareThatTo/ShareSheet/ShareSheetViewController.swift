//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/3/21.
//


import AVKit
import UIKit
import Photos
import Foundation


let defaultRect =  CGRect(x: 0, y: 0, width: 100, height: 100)

let shareOutletItemSize: CGFloat = 75

internal class ShareSheetViewController: UIViewController, UICollectionViewDelegate, UIAdaptivePresentationControllerDelegate {

    static let footerHeight: CGFloat = 100

    static let shareBackground : UIColor = UIColor(rgb: 0xF4F2FF)
    static let lightModeBackground : UIColor = UIColor(rgb: 0xF7F6FF)
    static let darkModeBackground : UIColor = UIColor(rgb: 0x0F0F0F)
    static let contentMargin: CGFloat = 20
    static let shareoutViewDimension: CGFloat = 80
    
    static var session : AVAudioSession?

    var shareOutlets: [ShareOutletProtocol.Type]
    
    private var content: Content?
    private let presentable: Presentable

    private var vidoeContentFuture: VideoContentFuture?
    
//    internal init(presentable: Presentable, videoProvider: VideoContentFutureProvider, title: String) throws
//    {
//        self.presentable = presentable
//        self.shareOutlets = ShareOutlets.outlets(forPeformableType: .video)
//        super.init(nibName: nil, bundle: nil)
//        self.vidoeContentFuture = VideoContentFuture.init(futureProvider: videoProvider, title: title)
//        {
//            (result) in
//            var analyticsEvent = AnalyticsEvent(event_name: "share_sheet.rendering_completed")
//            switch(result)
//            {
//            case .success(let videoContent):
//                self.content = videoContent
//            case .failure(let error):
//                analyticsEvent.error_string = error.localizedDescription
//            }
//            Analytics.shared.addEvent(event: analyticsEvent, context: self.analtyicsContext)
//        }
//        self.presentationController?.delegate = self
//    }
    private var completion: SharePresentationCompletion?
    
    internal init(provider: ContentProvider, completion: SharePresentationCompletion? = nil)
    {
        self.completion = completion
        self.presentable = provider
        self.shareOutlets = ShareOutlets.outlets(forPeformableType: .video)
        super.init(nibName: nil, bundle: nil)
        self.vidoeContentFuture = VideoContentFuture.init(futureProvider: provider, title: provider.title ?? "")
        {
            (result) in
            var analyticsEvent = AnalyticsEvent(event_name: "share_sheet.rendering_completed")
            switch(result)
            {
            case .success(let videoContent):
                self.content = videoContent
            case .failure(let error):
                analyticsEvent.error_string = error.localizedDescription
            }
            Analytics.shared.addEvent(event: analyticsEvent, context: self.analtyicsContext)
        }
        self.presentationController?.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let analtyicsContext: Context = {
        return Context()
    }()

    let contentView: UIView = {
        let contentView = UIView.init(frame: defaultRect)
        contentView.backgroundColor = lightModeBackground
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
    let shareToLabelView: UIView = {
        let shareToLabelView = UIView.init(frame: defaultRect)
        shareToLabelView.translatesAutoresizingMaskIntoConstraints = false
        shareToLabelView.backgroundColor = lightModeBackground
        
        let shareToLabel = UILabel.init(frame: defaultRect)
        shareToLabel.translatesAutoresizingMaskIntoConstraints = false
        shareToLabel.textAlignment = .center
        
        let labelText = NSAttributedString(string: "Share to",
                                           attributes: [
                                            NSAttributedString.Key.font: UIFont(name: "Avenir-Black", size: 16.0) as Any
                                           ])
        shareToLabel.attributedText = labelText
        
        shareToLabel.attributedText = NSAttributedString(string: "")
        
        shareToLabelView.addSubview(shareToLabel)
        NSLayoutConstraint.activate([
            shareToLabel.centerXAnchor.constraint(equalTo: shareToLabelView.centerXAnchor),
            shareToLabel.centerYAnchor.constraint(equalTo: shareToLabelView.centerYAnchor),
        ])
        
        
        
        return shareToLabelView
    }()

    let shareOutletView: UICollectionView = {
        // Collection View
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: shareOutletItemSize, height: shareOutletItemSize)
        let maxFullShareOutletsOnScreen = floor((UIScreen.main.bounds.width - 6.0) / shareOutletItemSize)
        let fullShareOutletsOnScreen = maxFullShareOutletsOnScreen
        let percentLastShareOutletOnScreen  = CGFloat(0.5)
        let spaceOccupiedByShareOutlets = (fullShareOutletsOnScreen + percentLastShareOutletOnScreen) * shareOutletItemSize
        layout.minimumLineSpacing = (UIScreen.main.bounds.width - spaceOccupiedByShareOutlets) / fullShareOutletsOnScreen

        let shareOutletView = UICollectionView.init(frame: defaultRect, collectionViewLayout: layout)
        shareOutletView.backgroundColor = lightModeBackground
        shareOutletView.translatesAutoresizingMaskIntoConstraints = false
        shareOutletView.collectionViewLayout = layout
        shareOutletView.register(ShareOutletCellView.self, forCellWithReuseIdentifier: "ShareThatToOutletCell")
        shareOutletView.showsHorizontalScrollIndicator = false
        
        shareOutletView.contentInset = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6)
        
        return shareOutletView
        
    }()

    let shareThatToBrandingView: UIView = {
        let shareThatToBrandingView = UIView.init(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        shareThatToBrandingView.translatesAutoresizingMaskIntoConstraints = false
        shareThatToBrandingView.backgroundColor = lightModeBackground
        
        return shareThatToBrandingView
    }()

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        Analytics.shared.addEvent(event: AnalyticsEvent(event_name: "share_sheet.loaded"), context: analtyicsContext)
        
        var userInterfaceModeString = "lightMode"
        if #available(iOS 12.0, *) {
            self.view.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? ShareSheetViewController.darkModeBackground : ShareSheetViewController.lightModeBackground
            contentView.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? ShareSheetViewController.darkModeBackground : ShareSheetViewController.lightModeBackground
            shareToLabelView.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? ShareSheetViewController.darkModeBackground : ShareSheetViewController.lightModeBackground
            shareOutletView.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? ShareSheetViewController.darkModeBackground : ShareSheetViewController.lightModeBackground
            shareThatToBrandingView.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? ShareSheetViewController.darkModeBackground : ShareSheetViewController.lightModeBackground
            userInterfaceModeString = self.traitCollection.userInterfaceStyle == .dark ? "darkMode" : "lightMode"
        }
        
        let shareThatToBrandingLabel = makeShareThatToLogoLabel(userInterfaceModeString)
        
        shareThatToBrandingView.addSubview(shareThatToBrandingLabel)
        NSLayoutConstraint.activate([
            shareThatToBrandingLabel.topAnchor.constraint(equalTo: shareThatToBrandingView.topAnchor, constant: 10),
            shareThatToBrandingLabel.centerXAnchor.constraint(equalTo: shareThatToBrandingView.centerXAnchor),
        ])
        
        self.view.addSubview(contentView)
        self.view.addSubview(shareToLabelView)
        self.view.addSubview(shareOutletView)
        self.view.addSubview(shareThatToBrandingView)

        ShareSheetViewController.session = AVAudioSession.sharedInstance()
        do {
            try ShareSheetViewController.session?.setCategory(.ambient, options: [])
            try ShareSheetViewController.session?.setActive(true) //Set to false to deactivate session
        } catch let error as NSError {
            Logger.shareThatToDebug(string: "[ShareSheetViewController] Unable to activate audio session", error: error)
        }

        shareOutletView.dataSource = self
        shareOutletView.delegate = self

        addShareOutletView()
        addContentView()
        addShareToLabelView()
        addShareThatToLogoButtonView()
    }
    
    private var presentedPresntable: Bool = false
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        if (presentedPresntable) { return }
        presentedPresntable = true
        self.presentable.presentOn(viewController: self, view: contentView)
    }

    func makeShareThatToLogoLabel(_ userInterfaceModeString: String) -> UILabel {
        let shareThatToBrandingLabel = UILabel(frame: defaultRect)
        
        // create an NSMutableAttributedString that we'll append everything to
        let font = UIFont(name: "Avenir-Black", size: 14.0)
        var stringAttributes: [NSAttributedString.Key:Any] = [:]
        if let unwrappedFont = font {
            stringAttributes[NSAttributedString.Key.font] = unwrappedFont
        }

        let shareThatToBrandingString = NSMutableAttributedString(string: "", attributes:stringAttributes)
        
        
        // create our NSTextAttachment
        
        let shareThatToLogo = NSTextAttachment()
        let logoFilepath = Bundle.module.path(forResource: "Assets/ShareThatTo-" + userInterfaceModeString, ofType: ".png")
        shareThatToLogo.image = UIImage(contentsOfFile: logoFilepath ?? "")

        shareThatToLogo.bounds = CGRect(x: 0, y:-2, width: 14, height: 14)
        
        
        // wrap the attachment in its own attributed string so we can append it
        let shareThatToLogoString = NSAttributedString(attachment: shareThatToLogo)

        // add the NSTextAttachment wrapper to our full string, then add some more text.
        shareThatToBrandingString.append(shareThatToLogoString)
        
        
        shareThatToBrandingString.append(NSAttributedString(string: "  Share That", attributes: stringAttributes ))

        // draw the result in a label
        shareThatToBrandingLabel.attributedText = shareThatToBrandingString


        shareThatToBrandingLabel.translatesAutoresizingMaskIntoConstraints = false
        
        shareThatToBrandingLabel.alpha = 0.618
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapShareThatToLogo))
        shareThatToBrandingLabel.addGestureRecognizer(recognizer)
        shareThatToBrandingLabel.isUserInteractionEnabled = true
        
        return shareThatToBrandingLabel
    }

    func addShareToLabelView() {
        let constraints = [
            shareToLabelView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            shareToLabelView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            shareToLabelView.heightAnchor.constraint(equalToConstant: 40),
            shareToLabelView.bottomAnchor.constraint(equalTo: shareOutletView.topAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    func addShareOutletView() {
        let constraints = [
            shareOutletView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            shareOutletView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            shareOutletView.heightAnchor.constraint(equalToConstant: ShareSheetViewController.shareoutViewDimension),
            shareOutletView.bottomAnchor.constraint(equalTo: shareThatToBrandingView.topAnchor, constant: -23)
        ]
        NSLayoutConstraint.activate(constraints)

    }
    
    func addShareThatToLogoButtonView() {
        let constraints = [
            shareThatToBrandingView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            shareThatToBrandingView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            shareThatToBrandingView.heightAnchor.constraint(equalToConstant: 80),
            shareThatToBrandingView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)

//        shareThatToBrandingView.addTarget(self, action: #selector(didTapShareThatToLogo), for: .touchUpInside)
    }


    func addContentView() {
        let constraints = [
            contentView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 48),
            contentView.bottomAnchor.constraint(equalTo: shareToLabelView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    // UICollectionView - state
    internal var spinningCellIndex: IndexPath? = nil
    internal var currentlySharingOulet: ShareOutletProtocol? = nil
}

// MARK: Button Responders

extension ShareSheetViewController {

    @objc func didTapShareThatToLogo()
    {
        Analytics.shared.addEvent(event: AnalyticsEvent(event_name: "share_sheet.logo_tapped"), context: analtyicsContext)
        
        
        let slug = ApplicationDatastore.shared.application?.slug
        if let url = URL(string: "https://sharethat.to/app-cta?ref=\(slug ?? "")") {
            UIApplication.shared.open(url, options:[:], completionHandler: nil)
        }
    }
}

// MARK: UICollectionView

extension ShareSheetViewController: UICollectionViewDataSource {

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return shareOutlets.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let shareOutletCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShareThatToOutletCell", for: indexPath) as! ShareOutletCellView
        if #available(iOS 12.0, *)
        {
            shareOutletCell.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? ShareSheetViewController.darkModeBackground : ShareSheetViewController.lightModeBackground
        }
        shareOutletCell.setupOutlet(shareOutlets[indexPath.row])
        
        var shouldSpin = false
        if let spinningIndex = spinningCellIndex
        {
            if (spinningIndex == indexPath)
            {
                shouldSpin = true
            }
        }
        shareOutletCell.spin(shouldSpin)
        return shareOutletCell
    }

    // State to ensure we can only tap one cell while the rendering is happening
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if (spinningCellIndex != nil) { return }
        let shareOutletClass: ShareOutletProtocol.Type = shareOutlets[indexPath.row]
        Analytics.shared.addEvent(event: AnalyticsEvent(event_name: "share_outlet.\(shareOutletClass.canonicalOutletName).started"))
        
        guard let unwrappedContent = self.content else
        {
            // We don't have the content yet, we're going to add a spinner
            spin(indexPath, true)
            Analytics.shared.addEvent(event: AnalyticsEvent(event_name: "share_sheet.rendering_incomplete_on_tap"), context: analtyicsContext)
            self.vidoeContentFuture?.addCompletion { (result) in
                self.spin(indexPath, false)
                switch(result)
                {
                case .success(let content):
                    self.share(content: content, to: shareOutletClass)
                case .failure(let error):
                    self.presentError(error: "Unable share right now: \(error.localizedDescription)")
                }
            }
            return
        }
        share(content: unwrappedContent, to: shareOutletClass)
    }

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath)
    {
        Haptics.shared.play(.light)
        guard let cell = shareOutletView.cellForItem(at: indexPath) else { return }
        cell.subviews[0].subviews[0].transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath){
        guard let cell = shareOutletView.cellForItem(at: indexPath) else { return }
        cell.subviews[0].subviews[0].transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
    }
    
    public func presentationControllerDidDismiss(
       _ presentationController: UIPresentationController)
     {
        // turn off audio session
        if ShareSheetViewController.session != nil {
            do {
                try ShareSheetViewController.session?.setActive(false) //Set to false to deactivate session
            } catch let error as NSError {
                Logger.shareThatToDebug(string: "Unable to activate audio session", error: error)
            }
        }
        Analytics.shared.addEvent(event: AnalyticsEvent(event_name: "share_sheet.cancelled"), context: analtyicsContext)
        // We didn't use any strategies
        content?.cleanupContent(with: [])
        
        self.completion?(.cancelled)
     }
    
    
    //MARK: - ShareOutletButtons

    private func share(content: Content, to: ShareOutletProtocol.Type)
    {
        
        DispatchQueue.main.async
        {
            // Safeguard to prevent popping two outlets at once
            if (self.currentlySharingOulet != nil) { return }
            
            var shareOutlet = to.init(content: content)
            self.currentlySharingOulet = shareOutlet
            shareOutlet.delegate = self
            shareOutlet.share(with: self)
        }
    }
    
    internal func shareComplete()
    {
        currentlySharingOulet = nil
    }
    
    private func spin(_ indexPath: IndexPath, _ enabled: Bool)
    {
        var reloadPaths = [indexPath]
        
        if let originalIndexPath: IndexPath = spinningCellIndex
        {
            reloadPaths.append(originalIndexPath)
        }
        
        if (enabled)
        {
            spinningCellIndex = indexPath
        }
        
        else
        {
            spinningCellIndex = nil
        }
        
        DispatchQueue.main.async
        {
            self.shareOutletView.reloadItems(at: reloadPaths)
        }
    }
    
    internal func presentError(error: String, completion: (() -> Void)? = nil)
    {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            completion?()
        }))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}

// MARK: ShareOutletDelegate

extension ShareSheetViewController: ShareOutletDelegate {

    func success(shareOutlet: ShareOutletProtocol, strategiesUsed: [ShareStretegyType])
    {
        shareComplete()
        
        // TODO: Add strategy type to event
        Analytics.shared.addEvent(event: AnalyticsEvent(event_name: "share_outlet.\(type(of: shareOutlet).canonicalOutletName).succeeded"), context: analtyicsContext)
        // If we didn't use the link preview, I think we can delete it
        content?.cleanupContent(with: strategiesUsed)
        // turn off audio session
        if ShareSheetViewController.session != nil {
            do {
                try ShareSheetViewController.session?.setActive(false) //Set to false to deactivate session
            } catch let error as NSError {
                Logger.shareThatToDebug(string: "Unable to activate audio session", error: error)
            }
        }
        DispatchQueue.main.async {
            self.presentingViewController?.dismiss(animated: true)
            self.completion?(.shared(destination: "\(type(of: shareOutlet).canonicalOutletName)"))
        }
    }

    func failure(shareOutlet: ShareOutletProtocol, error: String)
    {
        shareComplete()
        Analytics.shared.addEvent(event: AnalyticsEvent(event_name: "share_outlet.\(type(of: shareOutlet).canonicalOutletName).failed", error_string: error), context: analtyicsContext)
        presentError(error: error)
    }

    func cancelled(shareOutlet: ShareOutletProtocol)
    {
        shareComplete()
        Analytics.shared.addEvent(event: AnalyticsEvent(event_name: "share_outlet.\(type(of: shareOutlet).canonicalOutletName).cancelled"), context: analtyicsContext)
    }
}
