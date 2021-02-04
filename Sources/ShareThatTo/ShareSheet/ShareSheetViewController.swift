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


public class ShareSheetViewController: UIViewController, UICollectionViewDelegate {
    
    static let headerHeight:CGFloat = 60
    static let footerHeight: CGFloat = 150
    
    static let shareBackground = UIColor(rgb: 0xF4F2FF)
    static let contentBackground = UIColor(rgb: 0xF7F6FF)
    static let contentMargin: CGFloat = 20
    

    var shareable: ShareableContentWrapper?
    
    
    let headerView:UIView  = {
        let headerView = UIView.init(frame: defaultRect)
        headerView.backgroundColor = contentBackground
        
        let headerImageView = UIImageView.init(frame: defaultRect)
        headerImageView.image = UIImage(named: "HeaderLogo")
        headerImageView.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(headerImageView)
        
        let constraints = [
            headerImageView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            headerImageView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: 4 ),
            headerImageView.heightAnchor.constraint(equalToConstant: headerHeight * 0.8),
            headerImageView.widthAnchor.constraint(equalToConstant: headerHeight * 0.8),
            
        ]
        NSLayoutConstraint.activate(constraints)
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        return headerView
    }()
    
    let player: AVPlayerViewController = {
        
        let player = AVPlayer(url:  Bundle.main.url(forResource: "vertical", withExtension: "mp4")!)
        let controller = AVPlayerViewController()
        controller.player = player
        return controller
    }()
    
    let contentView: UIView = {
        let contentView = UIView.init(frame: defaultRect)
        contentView.backgroundColor = contentBackground
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
//        let player = AVPlayer(url:  Bundle.main.url(forResource: "video", withExtension: "mp4")!)
//        let controller = AVPlayerViewController()
//        controller.player = player
////        controller.view.frame = self.view.frame
//        contentView.addSubview(controller.view)
        

        
        return contentView
    }()
    
    
    
//    let shareOutletView: UIView = {
//        let shareOutletView = UIView.init(frame: defaultRect)
//        shareOutletView.translatesAutoresizingMaskIntoConstraints = false
//        shareOutletView.backgroundColor = GrowthShareViewController.shareBackground
//        return shareOutletView
//    }()
//
    let shareOutletView: UICollectionView = {
        // Collection View
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        layout.itemSize = CGSize(width: 50, height: 70)
        layout.minimumLineSpacing = 15
        
        
        let shareOutletView = UICollectionView.init(frame: defaultRect, collectionViewLayout: layout)
        shareOutletView.backgroundColor = ShareViewController.shareBackground
        shareOutletView.translatesAutoresizingMaskIntoConstraints = false
        

        shareOutletView.collectionViewLayout = layout
        shareOutletView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "MyCell")

        return shareOutletView
    }()
    
    let cancelButton: UIButton = {
        let cancelButton = UIButton.init(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.backgroundColor = UIColor(rgb: 0xECECEE)
        
        let cancelLabel = UILabel(frame: defaultRect)
        cancelLabel.text = "Cancel"
        
        cancelLabel.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addSubview(cancelLabel)
        NSLayoutConstraint.activate([
            cancelLabel.topAnchor.constraint(equalTo: cancelButton.topAnchor, constant: 10),
            cancelLabel.centerXAnchor.constraint(equalTo: cancelButton.centerXAnchor),
        ])
        return cancelButton
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(headerView)
        self.view.addSubview(contentView)
        self.view.addSubview(shareOutletView)
        self.view.addSubview(cancelButton)
        
        player.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(player.view)
        player.showsPlaybackControls = false
        print(player.player?.currentItem?.presentationSize ?? "nothing")
        
        NSLayoutConstraint.activate([
//            player.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            player.view.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
//            player.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            player.view.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            player.view.widthAnchor.constraint(equalTo: player.view.heightAnchor, multiplier: 720.0/1280.0),
            player.view.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            player.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
        ])
        
        
        // Setup player
        let layer = player.view.layer
        
        layer.masksToBounds = false
        layer.shadowRadius = 4
        layer.shadowOpacity = 1
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 0 , height: 4)
        
        
        self.addChild(player)
        player.player?.play()
        
        // Loop the video!
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.player?.currentItem, queue: .main) { [weak player] _ in
            player?.player?.seek(to: CMTime.zero)
            player?.player?.play()
        }
        
        shareOutletView.dataSource = self
        shareOutletView.delegate = self
        
        addHeader()
        addShareOutletView()
        addContentView()
        addCancelButtonView()
    }
    
    func addShareOutletView() {
        let constraints = [
            shareOutletView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            shareOutletView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            shareOutletView.heightAnchor.constraint(equalToConstant: 110),
            shareOutletView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor)
        ]
        NSLayoutConstraint.activate(constraints)

    }
    
    func addCancelButtonView() {
        let constraints = [
            cancelButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            cancelButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            cancelButton.heightAnchor.constraint(equalToConstant: ShareViewController.footerHeight * 0.6),
            cancelButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        
        cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
    }
    
    
    func addContentView() {
        let constraints = [
            contentView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            contentView.bottomAnchor.constraint(equalTo: shareOutletView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    func addHeader() {
        
        let constraints = [
            headerView.topAnchor.constraint(equalTo: self.view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: ShareViewController.headerHeight)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
}

// Mark - Button Responders

extension ShareViewController {

    @objc func didTapCancel() {
        self.dismiss(animated: true, completion:nil)
//        let url = Bundle.main.url(forResource: "vertical", withExtension: "mp4")!
//        do {
//            let videoData = NSData(contentsOf: url)!
//            let share = ShareImageInstagram()
//            share.delegate = self;
//            share.postToStories(data: videoData, image: UIImage(named: "FitnessBackground")!, backgroundTopColorHex: "#FFFFFF", backgroundBottomColorHex: "#FFFFFF", deepLink: "http://example.com")
        
//        DispatchQueue.main.async {
//
//        let pasteboardItems = [//"com.instagram.sharedSticker.stickerImage": image,
//                               "com.instagram.sharedSticker.backgroundTopColor" : "#FFFFFF",
//                               "com.instagram.sharedSticker.backgroundBottomColor" : "#FFFFFF",
//                               "com.instagram.sharedSticker.backgroundVideo": videoData,
//                               "com.instagram.sharedSticker.contentURL": "http://example.com"] as [String : Any]
//            let pasteboardOptions = [UIPasteboard.OptionsKey.expirationDate : NSDate().addingTimeInterval(60 * 5)]
//            UIPasteboard.general.setItems([pasteboardItems], options: pasteboardOptions)
//            UIApplication.shared.open(URL(string: "instagram-stories://share")!, options: [:], completionHandler: { (success) in
//
//            })
//        }
//        } catch {
//            print("Unable to load data: \(error)")
//        }
//        PHPhotoLibrary.shared().performChanges({
//            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
//                 }) { saved, error in
//                     if saved {
//
//
////                        let alertController = UIAlertController(title: "Your video was successfully saved", message: nil, preferredStyle: .alert)
////                        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
////                         alertController.addAction(defaultAction)
////                        self.present(alertController, animated: true, completion: nil)
//                        ShareImageInstagram().postToStories(data: NSData, image: <#T##UIImage#>, backgroundTopColorHex: <#T##String#>, backgroundBottomColorHex: <#T##String#>, deepLink: <#T##String#>)
//                     }
//                 }

        
    }

    
}
// MARK - UICollectionView

extension ShareViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return GrowthShareOulets.outlets.count
    }
      
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let myCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath)
        
        for view in myCell.contentView.subviews {
            view.removeFromSuperview()
        }
        
        // Find the right share outletn & load the image
        let shareOutlet: ShareOutlet = GrowthShareOulets.outlets[indexPath.row] as! ShareOutlet
        let image = UIImage(named: shareOutlet.imageName)
    
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        myCell.contentView.addSubview(imageView)
        
        let labelView = UILabel(frame: defaultRect)
        labelView.text = shareOutlet.outlateName
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.font = labelView.font.withSize(12)
        myCell.contentView.addSubview(labelView)
        
        let constraints = [
            imageView.topAnchor.constraint(equalTo: myCell.contentView.topAnchor),
            imageView.widthAnchor.constraint(equalTo: myCell.contentView.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: myCell.contentView.widthAnchor), // Make it a square
            imageView.centerXAnchor.constraint(equalTo: myCell.contentView.centerXAnchor),
            
            labelView.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            labelView.bottomAnchor.constraint(equalTo: myCell.contentView.bottomAnchor),
            labelView.centerXAnchor.constraint(equalTo: myCell.centerXAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
        return myCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var shareOutlet: ShareOutlet = GrowthShareOulets.outlets[indexPath.row] as! ShareOutlet
        shareOutlet.delegate = self
        guard let unwrappedShareable = self.shareable else {
            return
        }
        shareOutlet.share(shareable: unwrappedShareable, viewController: self)
    }
}


// Mark - ShareOutletDelegate

extension ShareViewController: ShareOutletDelegate {
    
    func success() {
        self.dismiss(animated: true) {
            //
        }
    }
    
    func failure(error: String) {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func cancelled(){
        
    }
}
