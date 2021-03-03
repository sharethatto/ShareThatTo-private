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

internal class ShareSheetViewController: UIViewController, UICollectionViewDelegate, UIAdaptivePresentationControllerDelegate {

    static let footerHeight: CGFloat = 100

    static let shareBackground : UIColor = UIColor(rgb: 0xF4F2FF)
    static let lightModeBackground : UIColor = UIColor(rgb: 0xF7F6FF)
    static let darkModeBackground : UIColor = UIColor(rgb: 0x0F0F0F)
    static let contentMargin: CGFloat = 20
    static let shareoutViewDimension: CGFloat = 80
    static let shareOutletItemSize: CGFloat = 75
    
    static var session : AVAudioSession?
    
    var content: Content
    var shareOutlets: [ShareOutletProtocol]

    
    internal init(videoURL: URL, title: String) throws {
        // TODO: Fix this with a delegate proxy so we don't break other callers
        // https://stackoverflow.com/questions/26953559/in-swift-how-do-i-have-a-uiscrollview-subclass-that-has-an-internal-and-externa
        
        self.content = try VideoContent(videoURL: videoURL, title: title)
        self.shareOutlets = ShareOutlets.outlets(forPeformable: self.content)
        
        let avPlayer =  AVPlayer(url:  videoURL)
        let controller = AVPlayerViewController()
        controller.player = avPlayer
        self.player = controller
        super.init(nibName: nil, bundle: nil)
        self.presentationController?.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    let player: AVPlayerViewController

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
        
        
        shareToLabelView.addSubview(shareToLabel)
        NSLayoutConstraint.activate([
//            shareToLabel.topAnchor.constraint(equalTo: shareToLabelView.topAnchor, constant: 0),
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
        let maxFullShareOutletsOnScreen = floor(UIScreen.main.bounds.width / shareOutletItemSize)
        let fullShareOutletsOnScreen = maxFullShareOutletsOnScreen - 1
        let percentLastShareOutletOnScreen  = CGFloat(0.5)
        let spaceOccupiedByShareOutlets = (fullShareOutletsOnScreen + percentLastShareOutletOnScreen) * shareOutletItemSize
        layout.minimumLineSpacing = (UIScreen.main.bounds.width - spaceOccupiedByShareOutlets) / fullShareOutletsOnScreen

        let shareOutletView = UICollectionView.init(frame: defaultRect, collectionViewLayout: layout)
        shareOutletView.backgroundColor = lightModeBackground
        shareOutletView.translatesAutoresizingMaskIntoConstraints = false
        shareOutletView.collectionViewLayout = layout
        shareOutletView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "ShareThatToOutletCell")
        shareOutletView.showsHorizontalScrollIndicator = false
            
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

        player.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(player.view)
        player.showsPlaybackControls = false

        NSLayoutConstraint.activate([
            player.view.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            player.view.widthAnchor.constraint(equalTo: player.view.heightAnchor, multiplier: 720.0/1280.0),
            player.view.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            player.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
        
        ShareSheetViewController.session = AVAudioSession.sharedInstance()
        do {
            try ShareSheetViewController.session?.setCategory(.ambient, options: [])
            try ShareSheetViewController.session?.setActive(true) //Set to false to deactivate session
        } catch let error as NSError {
            shareThatToDebug(string: "[ShareSheetViewController] Unable to activate audio sessio", error: error)
        }

        // Setup player
        self.addChild(player)
        player.player?.isMuted = true
        player.player?.play()

        // Loop the video!
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.player?.currentItem, queue: .main) { [weak player] _ in
            player?.player?.seek(to: CMTime.zero)
            player?.player?.play()
        }

        shareOutletView.dataSource = self
        shareOutletView.delegate = self

        addShareOutletView()
        addContentView()
        addShareToLabelView()
        addShareThatToLogoButtonView()
    }
    
    func makeShareThatToLogoLabel(_ userInterfaceModeString: String) -> UILabel {
        let shareThatToBrandingLabel = UILabel(frame: defaultRect)
        
        // create an NSMutableAttributedString that we'll append everything to
        let font = UIFont(name: "Avenir-Black", size: 14.0)
        var stringAttributes: [NSAttributedString.Key:Any] = [:]
        if let unwrappedFont = font {
            stringAttributes[NSAttributedString.Key.font] = unwrappedFont
        }

        let shareThatToBrandingString = NSMutableAttributedString(string: "Powered by ", attributes:stringAttributes)
        
        
        // create our NSTextAttachment
        
        let shareThatToLogo = NSTextAttachment()
        let logoFilepath = Bundle.module.path(forResource: "Assets/ShareThatTo-" + userInterfaceModeString, ofType: ".png")
        shareThatToLogo.image = UIImage(contentsOfFile: logoFilepath ?? "")

        shareThatToLogo.bounds = CGRect(x: 0, y:-2, width: 14, height: 14)
        
        
        // wrap the attachment in its own attributed string so we can append it
        let shareThatToLogoString = NSAttributedString(attachment: shareThatToLogo)

        // add the NSTextAttachment wrapper to our full string, then add some more text.
        shareThatToBrandingString.append(shareThatToLogoString)
        
        
        shareThatToBrandingString.append(NSAttributedString(string: " Share That To", attributes: stringAttributes ))

        // draw the result in a label
        shareThatToBrandingLabel.attributedText = shareThatToBrandingString


        shareThatToBrandingLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return shareThatToBrandingLabel
    }

    func addShareToLabelView() {
        let constraints = [
            shareToLabelView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            shareToLabelView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            shareToLabelView.heightAnchor.constraint(equalToConstant: 35),
            shareToLabelView.bottomAnchor.constraint(equalTo: shareOutletView.topAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    func addShareOutletView() {
        let constraints = [
//            shareOutletView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            shareOutletView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            shareOutletView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            shareOutletView.heightAnchor.constraint(equalToConstant: ShareSheetViewController.shareoutViewDimension),
            shareOutletView.bottomAnchor.constraint(equalTo: shareThatToBrandingView.topAnchor)
        ]
        NSLayoutConstraint.activate(constraints)

    }
    
    func addShareThatToLogoButtonView() {
        let constraints = [
            shareThatToBrandingView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            shareThatToBrandingView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            shareThatToBrandingView.heightAnchor.constraint(equalToConstant: ShareSheetViewController.footerHeight * 0.6),
            shareThatToBrandingView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)

//        shareThatToBrandingView.addTarget(self, action: #selector(didTapShareThatToLogo), for: .touchUpInside)
    }


    func addContentView() {
        let constraints = [
            contentView.topAnchor.constraint(equalTo: self.view.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: shareToLabelView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
    }

}

// MARK: Button Responders

extension ShareSheetViewController {

    @objc func didTapShareThatToLogo() {
        
        Analytics.shared.addEvent(event: AnalyticsEvent(event_name: "share_sheet.logo_tapped"), context: analtyicsContext)
        
    }


}
// MARK: UICollectionView

extension ShareSheetViewController: UICollectionViewDataSource {

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shareOutlets.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let myCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShareThatToOutletCell", for: indexPath)
        if #available(iOS 12.0, *) {
            myCell.backgroundColor = self.traitCollection.userInterfaceStyle == .dark ? ShareSheetViewController.darkModeBackground : ShareSheetViewController.lightModeBackground
        }

        for view in myCell.contentView.subviews {
            view.removeFromSuperview()
        }

        // Find the right share outletn & load the image
        let shareOutlet: ShareOutletProtocol = shareOutlets[indexPath.row]
        let image = type(of: shareOutlet).buttonImage() //UIImage(named: shareOutlet.imageName)

        let label = UILabel()
        let labelText = NSAttributedString(string: type(of: shareOutlet).outletName,
                                           attributes: [
                                            NSAttributedString.Key.font: UIFont(name: "Avenir", size: 12.0) as Any
                                           ])
        label.attributedText = labelText
        label.textAlignment = .center
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        myCell.contentView.addSubview(imageView)
        myCell.contentView.addSubview(label)

        let constraints = [
            imageView.topAnchor.constraint(equalTo: myCell.contentView.topAnchor),
            imageView.widthAnchor.constraint(equalTo: myCell.contentView.widthAnchor, multiplier: 0.70),
            imageView.heightAnchor.constraint(equalTo: myCell.contentView.widthAnchor, multiplier: 0.70), // Make it a square
            imageView.centerXAnchor.constraint(equalTo: myCell.contentView.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: myCell.contentView.bottomAnchor),
            label.widthAnchor.constraint(equalTo: myCell.contentView.widthAnchor),
            label.heightAnchor.constraint(equalTo: myCell.contentView.widthAnchor, multiplier: 0.2), // Make it a square
            label.centerXAnchor.constraint(equalTo: myCell.contentView.centerXAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        return myCell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var shareOutlet: ShareOutletProtocol = shareOutlets[indexPath.row]
        shareOutlet.delegate = self
        Analytics.shared.addEvent(event: AnalyticsEvent(event_name: "share_outlet.\(type(of: shareOutlet).canonicalOutletName).started"))
        shareOutlet.share(with: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath){
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
                print("Unable to activate audio session:  \(error.localizedDescription)")
            }
        }
        Analytics.shared.addEvent(event: AnalyticsEvent(event_name: "share_sheet.cancelled"), context: analtyicsContext)
        // We didn't use any strategies
        content.cleanupContent(with: [])
//        self.dismiss(animated: true, completion:nil)
       // Only called when the sheet is dismissed by DRAGGING.
       // You'll need something extra if you call .dismiss() on the child.
       // (I found that overriding dismiss in the child and calling
       // presentationController.delegate?.presentationControllerDidDismiss
       // works well).
     }
    
    
}



// MARK: ShareOutletDelegate

extension ShareSheetViewController: ShareOutletDelegate {

    func success(shareOutlet: ShareOutletProtocol, strategiesUsed: [ShareStretegyType]) {
        // TODO: Add strategy type to event
        Analytics.shared.addEvent(event: AnalyticsEvent(event_name: "share_outlet.\(type(of: shareOutlet).canonicalOutletName).succeeded"), context: analtyicsContext)
        // If we didn't use the link preview, I think we can delete it
        content.cleanupContent(with: strategiesUsed)
        // turn off audio session
        if ShareSheetViewController.session != nil {
            do {
                try ShareSheetViewController.session?.setActive(false) //Set to false to deactivate session
            } catch let error as NSError {
                print("Unable to activate audio session:  \(error.localizedDescription)")
            }
        }
        DispatchQueue.main.async {
            self.presentingViewController?.dismiss(animated: true)
        }
    }

    func failure(shareOutlet: ShareOutletProtocol, error: String)
    {
        Analytics.shared.addEvent(event: AnalyticsEvent(event_name: "share_outlet.\(type(of: shareOutlet).canonicalOutletName).failed", error_string: error), context: analtyicsContext)
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")        
        }))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }

    func cancelled(shareOutlet: ShareOutletProtocol){
        Analytics.shared.addEvent(event: AnalyticsEvent(event_name: "share_outlet.\(type(of: shareOutlet).canonicalOutletName).cancelled"), context: analtyicsContext)
    }
}
