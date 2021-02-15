//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/11/21.
//

import UIKit
import Foundation



class ShareOutletUtils
{
    public static let shared = ShareOutletUtils()
    
    private static func canOpenURLScheme(scheme:String) -> Bool
    {
        var components = URLComponents()
        components.scheme = scheme
        components.path = "/"
        guard let url = components.url else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
    
    // https://github.com/facebook/facebook-ios-sdk/blob/96fe45e6ee25e349d08b70ac7b205909f5657994/FBSDKCoreKit/FBSDKCoreKit/Internal/FBSDKInternalUtility.h#L25
    private static let fbsdkCanOpenURLFacebook = "fbauth2"
    
    // https://github.com/facebook/facebook-ios-sdk/blob/master/FBSDKCoreKit/FBSDKCoreKit/Internal/FBSDKInternalUtility.m#L376
    static private let isFacebookAppInstalledOnce:Once<ShareOutletUtils.Type, Bool> = Once { myself in
        return canOpenURLScheme(scheme: ShareOutletUtils.fbsdkCanOpenURLFacebook)
    }
    static var isFacebookAppInstalled: Bool {
        get { self.isFacebookAppInstalledOnce.once(self, defaultValue: false) }
    }
    
    
    // https://github.com/facebook/facebook-ios-sdk/blob/master/FBSDKCoreKit/FBSDKCoreKit/Internal/FBSDKInternalUtility.h#L27
    private static let fbsdkCanOpenURLMessenger = "fb-messenger-share-api"
    private static let isMessengerAppInstalledOnce:Once<ShareOutletUtils.Type, Bool> = Once { myself in
        return canOpenURLScheme(scheme: ShareOutletUtils.fbsdkCanOpenURLMessenger)
    }
    static var isMessengerAppInstalled: Bool {
        get { self.isMessengerAppInstalledOnce.once(self, defaultValue: false) }
    }
    
    
    private static let instagramCanOpenURL = "instagram"
    private static let isInstagramAppInstalledOnce:Once<ShareOutletUtils.Type, Bool> = Once { myself in
        return canOpenURLScheme(scheme: ShareOutletUtils.instagramCanOpenURL)
    }
    static var isInstagramAppInstalled: Bool {
        get { self.isInstagramAppInstalledOnce.once(self, defaultValue: false) }
    }
    
    
    private static let twitterCanOpenURL = "twitter"
    private static let isTwitterAppInstalledOnce:Once<ShareOutletUtils.Type, Bool> = Once { myself in
        return canOpenURLScheme(scheme: ShareOutletUtils.twitterCanOpenURL)
    }
    static var isTwitterAppInstalled: Bool {
        get { self.isTwitterAppInstalledOnce.once(self, defaultValue: false) }
    }
}
