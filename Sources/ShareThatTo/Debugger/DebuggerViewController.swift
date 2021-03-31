//
//  File.swift
//  
//
//  Created by Brian Anglin on 3/28/21.
//

import UIKit
import Foundation



class DebuggerViewController: UIViewController
{
    
    struct DebugViewControllerProviders {
        public static let defaultProviders = DebugViewControllerProviders()
        public let network: NetworkDebugProtocol
        public init(network: NetworkDebugProtocol = Network())
        {
            self.network = network
        }
    }
    
    private let providers: DebugViewControllerProviders
    private let context: UGCContext
    public init(context: UGCContext, providers: DebugViewControllerProviders = DebugViewControllerProviders.defaultProviders)
    {
        self.context = context
        self.providers = providers
        super.init(nibName: nil, bundle: nil)

        // Upload the context to the server
        self.providers.network.uploadContext(context: context) { (result) in
            DispatchQueue.main.async {
                switch (result) {
                case .success(let response):
                    self.codeView.isHidden = false
                    self.codeView.text = response.code
                case .failure(let error):
                    print("Something went wrong: \(error.localizedDescription)")
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var codeView: UILabel = {
       let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        label.font = UIFont.boldSystemFont(ofSize: 50)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var openLinkView: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        label.font = UIFont.boldSystemFont(ofSize: 50)
        label.text = "Please visit \nhttps://sharethat.to/go \n to get started!"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad()
    {
        self.view.backgroundColor = UIColor.gray
        self.view.addSubview(codeView)
        self.view.addSubview(openLinkView)
        
        codeView.isHidden = true
        
        NSLayoutConstraint.activate([
            codeView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            codeView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            
            openLinkView.topAnchor.constraint(equalTo: codeView.bottomAnchor, constant: 100),
            openLinkView.centerXAnchor.constraint(equalTo: codeView.centerXAnchor),
        ])
    }
}
