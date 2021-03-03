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
    
    public func presentShareSheet(on viewController: UIViewController, videoURL: URL, title: String, completion: ((Swift.Error?) -> Void)?)
    {
        guard let _ = authenticationDatastore.apiKey else {
            let error = NSError(domain: "ShareThatTo", code: 1, userInfo: ["reason": "API key must be set"])
            shareThatToDebug(string: "Please set ShareThatToClientId in your Info.plist", error: error)
            completion?(error)
            return
        }
        DispatchQueue.main.async {
            do {
                let vc = try ShareSheetViewController.init(videoURL: videoURL, title: title)
                viewController.present(vc, animated: true) {
                    completion?(nil)
                }
            } catch let error {
                shareThatToDebug(string: "Unable to present Share Sheet", error: error)
                completion?(error)
            }
        }
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

