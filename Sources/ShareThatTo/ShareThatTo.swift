import UIKit

public class ShareThatTo
{
    // Singleton
    public static let shared = ShareThatTo()
    private let lifecycle: LifecycleProtocol
    private var authenticationDatastore: AuthenticationDatastoreProtocol
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
    
    
    public func share(videoURL: URL, title: String) throws -> ShareSheetViewController
    {
        guard let _ = authenticationDatastore.apiKey else { throw NSError(domain: "ShareThatTo", code: 1, userInfo: ["reason": "API key must be set"]) }
        return try ShareSheetViewController.init(videoURL: videoURL, title: title)
    }
    
    // Public setup
    public static func share(videoURL: URL, title: String) throws -> ShareSheetViewController
    {
        try shared.share(videoURL: videoURL, title: title)
    }
}

