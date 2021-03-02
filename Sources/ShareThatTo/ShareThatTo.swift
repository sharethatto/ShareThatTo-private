import UIKit

//public protocol ShareThatToApplicationLifecycleProtocol
//{
//   
//}

// This contains the lifecycle hooks that other intergations need
public protocol ShareThatToLifecycleDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool
}

public class ShareThatTo: ShareThatToLifecycleDelegate
{
    // Singleton
    public static let shared = ShareThatTo()
    private let lifecycle: LifecycleProtocol
    private var authenticationDatastore: AuthenticationDatastoreProtocol
    internal init(lifecycle: LifecycleProtocol = Lifecycle(), authenticationDatastore: AuthenticationDatastoreProtocol = Datastore.shared.authenticationDatastore)
    {
        self.lifecycle = lifecycle
        self.authenticationDatastore = authenticationDatastore
        self.lifecycle.start()
    }
    
    
    public func share(videoURL: URL, title: String) throws -> (UIViewController & UIAdaptivePresentationControllerDelegate)
    {
        guard let _ = authenticationDatastore.apiKey else { throw NSError(domain: "ShareThatTo", code: 1, userInfo: ["reason": "API key must be set"]) }
        return try ShareSheetViewController.init(videoURL: videoURL, title: title)
    }
    
    // Public setup
    public static func share(videoURL: URL, title: String) throws -> (UIViewController & UIAdaptivePresentationControllerDelegate)
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
    
    // TODO: Maybe automatically go find all the available share outlets?
    // Would make installing Facebook and Snapchat easier 
    // https://stackoverflow.com/questions/42824541/swift-3-1-deprecates-initialize-how-can-i-achieve-the-same-thing/42824542#42824542
    public func register(outlet: ShareOutletProtocol.Type)
    {
        ShareOutlets.availableOutlets.append(outlet)
    }
}

