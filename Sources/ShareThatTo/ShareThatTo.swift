import UIKit

//public protocol ShareThatToApplicationLifecycleProtocol
//{
//   
//}

// This contains the lifecycle hooks that other intergations need
protocol ShareThatToLifecycleDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool
}

public class ShareThatTo: ShareThatToLifecycleDelegate
{
    // Singleton
    public static let shared = ShareThatTo()
    private let lifecycle: LifecycleProtocol
    private var authenticationDatastore: AuthenticationDatastoreProtocol
    internal var snapchatShare: SnapchatOutletProtocol.Type?
    internal init(lifecycle: LifecycleProtocol = Lifecycle(), authenticationDatastore: AuthenticationDatastoreProtocol = Datastore.shared.authenticationDatastore)
    {
        self.lifecycle = lifecycle
        self.authenticationDatastore = authenticationDatastore
    }
    
    // Public configuration
    @discardableResult
    public func configure(apiKey: String) -> ShareThatTo
    {
        authenticationDatastore.apiKey = apiKey
        
        // Whenever we've set the api key, start refreshing data again
        lifecycle.start()
        return self
    }
    
    
    public func share(videoURL: URL, title: String) throws -> UIViewController
    {
        guard let _ = authenticationDatastore.apiKey else { throw NSError(domain: "ShareThatTo", code: 1, userInfo: ["reason": "API key must be set"]) }
        return try ShareSheetViewController.init(videoURL: videoURL, title: title)
    }
    
    // Public setup
    public static func share(videoURL: URL, title: String) throws -> UIViewController
    {
        try shared.share(videoURL: videoURL, title: title)
    }
    
    @discardableResult
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        
        ShareOutlets.forwardLifecycleDelegate { (shareLifecycle) in
            let _ = shareLifecycle.application(application, didFinishLaunchingWithOptions: launchOptions)
        }
        return true
    }
    
    @discardableResult
    public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool
    {
        ShareOutlets.forwardLifecycleDelegate { (shareLifecycle) in
            let _ = shareLifecycle.application(app, open: url, options: options)
        }
        return true
    }
    
    // Caller, calls this with a function that I can call when I want to share to snpa
    // TODO: [Re-enable snapchat] Change to public
    private func setupSnapchatShare(snapchatShare: SnapchatOutletProtocol.Type){
        self.snapchatShare = snapchatShare
    }
}

