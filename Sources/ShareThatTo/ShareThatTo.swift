import UIKit

//public protocol ShareThatToApplicationLifecycleProtocol
//{
//   
//}

// This contains the lifecycle hooks that other intergations need
public protocol ShareThatToLifecycleDelegate
{
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool
}

public class ShareThatTo: ShareThatToLifecycleDelegate
{
    // Singleton
    public static let shared = ShareThatTo()
    private let lifecycle: LifecycleProtocol
    private var authenticationDatastore: AuthenticationDatastoreProtocol
    private var contribDatastore: ContribDatastoreProtocol
    internal init(
        lifecycle: LifecycleProtocol = Lifecycle(),
        authenticationDatastore: AuthenticationDatastoreProtocol = Datastore.shared.authenticationDatastore,
        contribDatastore: ContribDatastoreProtocol = ContribDatastore.shared
    )
    {
        self.lifecycle = lifecycle
        self.authenticationDatastore = authenticationDatastore
        self.contribDatastore = contribDatastore
        self.lifecycle.start()
    }
    
//    public func presentShareSheet(on viewController: UIViewController, presentable: Presentable,  videoProvider: VideoContentFutureProvider, title: String, completion: ((Swift.Error?) -> Void)? = nil)
//    {
//        if authenticationDatastore.apiKey == nil  {
//            Logger.shareThatToDebug(string: "Please set ShareThatToClientId in your Info.plist")
//        }
//        DispatchQueue.main.async {
//            do {
//                let vc = try ShareSheetViewController.init(presentable: presentable, videoProvider: videoProvider, title: title)
//                viewController.present(vc, animated: true) {
//                    completion?(nil)
//                }
//            } catch let error {
//                Logger.shareThatToDebug(string: "Unable to present Share Sheet", error: error)
//                completion?(error)
//            }
//        }
//    }
    
//    public func present(ugc: ContentProvider, title: String, on: UIViewController)
//    {
//        if authenticationDatastore.apiKey == nil  {
//            Logger.shareThatToDebug(string: "Please set ShareThatToClientId in your Info.plist")
//        }
//        DispatchQueue.main.async {
//            do {
//                let vc = try ShareSheetViewController.init(provider: ugc, title: title)
//                on.present(vc, animated: true)
//            } catch let error {
//                Logger.shareThatToDebug(string: "Unable to present Share Sheet", error: error)
//            }
//        }
//    }

    
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
    
    
    public func configure(userId: String?)
    {
        self.contribDatastore.userId = userId
    }
    
    public func configure(apiKey: String)
    {
        self.authenticationDatastore.apiKey = apiKey
    }
    
    // TODO: Maybe automatically go find all the available share outlets?
    // Would make installing Facebook and Snapchat easier 
    // https://stackoverflow.com/questions/42824541/swift-3-1-deprecates-initialize-how-can-i-achieve-the-same-thing/42824542#42824542
    public func register(outlet: ShareOutletProtocol.Type)
    {
        ShareOutlets.availableOutlets.append(outlet)
    }
}

