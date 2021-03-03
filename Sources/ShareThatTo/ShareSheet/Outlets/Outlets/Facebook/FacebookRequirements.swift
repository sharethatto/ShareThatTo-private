//
//  File.swift
//  
//
//  Created by Brian Anglin on 3/3/21.
//

import Foundation
class FacebookRequirements: Requirements
{
    public init()
    {
        super.init(requirements: [
            RequiredPlistNonNil(requiredKey: "FacebookDisplayName"),
            RequiredPlistNonNil(requiredKey: "FacebookAppID"),
            RequiredApplicationQuerySchemes(requiredSchemes: [
                "fbapi",
                "fbapi20130214",
                "fbapi20130410",
                "fbapi20130702",
                "fbapi20131010",
                "fbapi20131219",
                "fbapi20140410",
                "fbapi20140116",
                "fbapi20150313",
                "fbapi20150629",
                "fbapi20160328",
                "fbauth",
                "fb-messenger-share-api",
                "fbauth2",
                "fbshareextension",
            ]),
//            RequiredCFBundleURLSchemes(requiredSchemes: ["fb" + facebookAppId]),
            PhotoRequirement(),
        ])
    }
}
