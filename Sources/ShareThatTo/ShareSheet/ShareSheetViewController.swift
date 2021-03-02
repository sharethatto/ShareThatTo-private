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

    static let shareBackground = UIColor(rgb: 0xF4F2FF)
    static let contentBackground = UIColor(rgb: 0xF7F6FF)
    static let contentMargin: CGFloat = 20
    
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
        contentView.backgroundColor = contentBackground
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
    let shareToLabelView: UIView = {
        let shareToLabelView = UIView.init(frame: defaultRect)
        shareToLabelView.translatesAutoresizingMaskIntoConstraints = false
        shareToLabelView.backgroundColor = contentBackground
        
        let shareToLabel = UILabel.init(frame: defaultRect)
        shareToLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let labelText = NSAttributedString(string: "Share To", attributes: [NSAttributedString.Key.font: UIFont(name: "Avenir-Black", size: 18.0)])
        
        shareToLabel.attributedText = labelText
        
        
        shareToLabelView.addSubview(shareToLabel)
        NSLayoutConstraint.activate([
            shareToLabel.topAnchor.constraint(equalTo: shareToLabelView.topAnchor, constant: 0),
            shareToLabel.centerXAnchor.constraint(equalTo: shareToLabelView.centerXAnchor),
        ])
        return shareToLabelView
    }()

    let shareOutletView: UICollectionView = {
        // Collection View
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        layout.itemSize = CGSize(width: 60, height: 60)
        layout.minimumLineSpacing = 15

        let shareOutletView = UICollectionView.init(frame: defaultRect, collectionViewLayout: layout)
        shareOutletView.backgroundColor = ShareSheetViewController.contentBackground
        shareOutletView.translatesAutoresizingMaskIntoConstraints = false
        shareOutletView.collectionViewLayout = layout
        shareOutletView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "ShareThatToOutletCell")
        shareOutletView.showsHorizontalScrollIndicator = false
            
        return shareOutletView
    }()

    let shareThatToBrandingButton: UIButton = {
        let cancelButton = UIButton.init(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.backgroundColor = contentBackground
        
        let cancelLabel = UILabel(frame: defaultRect)
        
        // create an NSMutableAttributedString that we'll append everything to
        let font = UIFont(name: "Avenir-Black", size: 18.0)
        var stringAttributes: [NSAttributedString.Key:Any] = [:]
        if let unwrappedFont = font {
            stringAttributes[NSAttributedString.Key.font] = unwrappedFont
        }

        let fullString = NSMutableAttributedString(string: "Powered by", attributes:stringAttributes)
        
        
        // create our NSTextAttachment
        
        let image1Attachment = NSTextAttachment()
        let filepath = Bundle.module.path(forResource: "Assets/ShareThatTo", ofType: ".png")
        image1Attachment.image = UIImage(contentsOfFile: filepath ?? "")

        image1Attachment.bounds = CGRect(x: 6, y:-5, width: 25, height: 25)
        
        // wrap the attachment in its own attributed string so we can append it
        let image1String = NSAttributedString(attachment: image1Attachment)

        // add the NSTextAttachment wrapper to our full string, then add some more text.
        fullString.append(image1String)
        
        
        fullString.append(NSAttributedString(string: " Share That To", attributes: stringAttributes ))

        // draw the result in a label
        cancelLabel.attributedText = fullString


        cancelLabel.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addSubview(cancelLabel)
        NSLayoutConstraint.activate([
            cancelLabel.topAnchor.constraint(equalTo: cancelButton.topAnchor, constant: 10),
            cancelLabel.centerXAnchor.constraint(equalTo: cancelButton.centerXAnchor),
        ])
        return cancelButton
    }()

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        Analytics.shared.addEvent(event: AnalyticsEvent(event_name: "share_sheet.loaded"), context: analtyicsContext)
        
        self.view.addSubview(contentView)
        self.view.addSubview(shareToLabelView)
        self.view.addSubview(shareOutletView)
        self.view.addSubview(shareThatToBrandingButton)

        player.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(player.view)
        player.showsPlaybackControls = false

        NSLayoutConstraint.activate([
            player.view.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            player.view.widthAnchor.constraint(equalTo: player.view.heightAnchor, multiplier: 720.0/1280.0),
            player.view.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            player.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
        ])

        // Setup player
        self.addChild(player)
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
            shareOutletView.heightAnchor.constraint(equalToConstant: 60),
            shareOutletView.bottomAnchor.constraint(equalTo: shareThatToBrandingButton.topAnchor)
        ]
        NSLayoutConstraint.activate(constraints)

    }

    func addShareThatToLogoButtonView() {
        let constraints = [
            shareThatToBrandingButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            shareThatToBrandingButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            shareThatToBrandingButton.heightAnchor.constraint(equalToConstant: ShareSheetViewController.footerHeight * 0.6),
            shareThatToBrandingButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)

        shareThatToBrandingButton.addTarget(self, action: #selector(didTapShareThatToLogo), for: .touchUpInside)
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

        for view in myCell.contentView.subviews {
            view.removeFromSuperview()
        }

        // Find the right share outletn & load the image
        let shareOutlet: ShareOutletProtocol = shareOutlets[indexPath.row]
        let image = type(of: shareOutlet).buttonImage() //UIImage(named: shareOutlet.imageName)

        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        myCell.contentView.addSubview(imageView)


        let constraints = [
            imageView.topAnchor.constraint(equalTo: myCell.contentView.topAnchor),
            imageView.widthAnchor.constraint(equalTo: myCell.contentView.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: myCell.contentView.widthAnchor), // Make it a square
            imageView.centerXAnchor.constraint(equalTo: myCell.contentView.centerXAnchor),
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
    
    
    public func presentationControllerDidDismiss(
       _ presentationController: UIPresentationController)
     {
        Analytics.shared.addEvent(event: AnalyticsEvent(event_name: "share_sheet.cancelled"), context: analtyicsContext)
        // We didn't use any strategies
        content.cleanupContent(with: [])
//        self.dismiss(animated: true, completion:nil)
       // Only called when the sheet is dismissed by DRAGGING.
       // You'll need something extra if you call .dismiss() on the child.
       // (I found that overriding dismiss in the child and calling
       // presentationController.delegate?.presentationControllerDidDismiss
       // works well).
        print("[ShareThatTo] Dismissed by dragging")
     }
    
    
}



// MARK: ShareOutletDelegate

extension ShareSheetViewController: ShareOutletDelegate {

    func success(shareOutlet: ShareOutletProtocol, strategiesUsed: [ShareStretegyType]) {
        // TODO: Add strategy type to event
        Analytics.shared.addEvent(event: AnalyticsEvent(event_name: "share_outlet.\(type(of: shareOutlet).canonicalOutletName).succeeded"), context: analtyicsContext)
        // If we didn't use the link preview, I think we can delete it
        content.cleanupContent(with: strategiesUsed)
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


