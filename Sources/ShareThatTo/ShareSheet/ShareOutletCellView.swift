//
//  File.swift
//  
//
//  Created by Brian Anglin on 3/14/21.
//

import UIKit
import Foundation

class ShareOutletCellView: UICollectionViewCell
{
    
    private let labelView: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        imageView.layer.cornerRadius = shareOutletItemSize / 2.0
        return imageView
    }()

    private var spinnerView: UIActivityIndicatorView = {
        let spinnerView = UIActivityIndicatorView(style: .whiteLarge)
        spinnerView.translatesAutoresizingMaskIntoConstraints = false
        spinnerView.hidesWhenStopped = true
        return spinnerView
    }()
    
    private var viewSetup = false
    
    override public func layoutSubviews()
    {
        super.layoutSubviews()
        setup()
    }
    
    private func setup()
    {
        if (viewSetup) { return }
        viewSetup = true
        
        self.contentView.addSubview(imageView)
        self.contentView.addSubview(labelView)
        self.contentView.addSubview(spinnerView)
        
        let constraints = [
            imageView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            imageView.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, multiplier: 0.70),
            imageView.heightAnchor.constraint(equalTo: self.contentView.widthAnchor, multiplier: 0.70), // Make it a square
            imageView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            
//            spinnerView.topAnchor.constraint(equalTo: self.imageView.topAnchor),
//            spinnerView.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, multiplier: 0.70),
//            spinnerView.heightAnchor.constraint(equalTo: self.contentView.widthAnchor, multiplier: 0.70), // Make it a square
//            spinnerView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            spinnerView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            spinnerView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            
            labelView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            labelView.widthAnchor.constraint(equalTo: self.contentView.widthAnchor),
            labelView.heightAnchor.constraint(equalTo: self.contentView.widthAnchor, multiplier: 0.2),
            labelView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    public func setupOutlet(_ outlet: ShareOutletProtocol.Type)
    {
        let labelText = NSAttributedString(
            string: outlet.outletName,
            attributes: [
                NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 12.0) as Any,
            ]
        )
        labelView.attributedText = labelText
        
        
        let image = outlet.buttonImage()
        imageView.image = image
    }
    
    public func spin(_ enabled: Bool)
    {
        if (enabled)
        {
            spinnerView.startAnimating()
            imageView.layer.backgroundColor = UIColor.black.cgColor
            imageView.layer.opacity = 0.5
        }
        else
        {
            imageView.layer.backgroundColor = UIColor.clear.cgColor
            imageView.layer.opacity = 1.0
            spinnerView.stopAnimating()
        }
        
//        setup()
//        if (enabled)
//        {
//            print("yo")
//        }
//        // Check if we're already in the right state
//        if (enabled && spinnerView != nil) || (!enabled && spinnerView == nil) { return }
//
//        if (enabled)
//        {
//            spinnerView = UIActivityIndicatorView(style: .white)
//            spinnerView?.translatesAutoresizingMaskIntoConstraints = false
//            self.contentView.addSubview(spinnerView!)
//            spinnerView?.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
//            spinnerView?.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
//
//        }
//        else
//        {
//            spinnerView?.removeFromSuperview()
//            spinnerView = nil
//        }
    }
}
