//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/17/21.
//

import Foundation

protocol ShareOutletConfigurationRequirements {
    
}

protocol ShareOutletRequirementProtocol
{
    func met(plist: [String:Any?]) -> Bool
}

struct PlistBuddyInstructionHelper
{
    static let plistBuddyPath: String = "/usr/libexec/PlistBuddy"
    let commands: [String]
    public init(commands: [String])
    {
        self.commands = commands
    }
    
    public static func addValueToArray(arrayName: String, value: String) -> String
    {
        return "Add :\(arrayName):0 string \(value)"
    }
    
    public func command() -> String
    {
        let wrappedCommands = commands.map { (cmd) -> String in
            return "-c \"\(cmd)\""
        }
        return "\(type(of: self).plistBuddyPath) \(wrappedCommands.joined(separator: " ")) <path/to/info.plist>"
    }
}

struct RequiredApplicationQuerySchemes: ShareOutletRequirementProtocol
{
    let requiredSchemes:[String]
    public init(requiredSchemes: [String])
    {
        self.requiredSchemes = requiredSchemes
    }
    
    public func met(plist: [String : Any?]) -> Bool
    {
        guard let schemes = plist["LSApplicationQueriesSchemes"] as? [String] else {
            return false
        }
        return Set(requiredSchemes).isSubset(of: Set(schemes))
    }
    
    public func instructions(plist: [String:Any?]) -> String?
    {
        return PlistBuddyInstructionHelper(commands: self.requiredSchemes.map { (str) -> String in
            return PlistBuddyInstructionHelper.addValueToArray(arrayName: "LSApplicationQueriesSchemes", value: str)
        }).command()
    }
}

struct RequiredCFBundleURLSchemes: ShareOutletRequirementProtocol
{
    let requiredSchemes:[String]
    public init(requiredSchemes: [String])
    {
        self.requiredSchemes = requiredSchemes
    }
    
    public func met(plist: [String : Any?]) -> Bool
    {
        guard let urlTypes = plist["CFBundleURLTypes"] as? [[String:Any?]] else {
            return false
        }
        
        guard let schemesAny = (urlTypes.first { (dictionary) -> Bool in
            return dictionary["CFBundleURLSchemes"] != nil
        }?["CFBundleURLSchemes"]) else {
            return false
        }
        
        guard let schemes = schemesAny as? [String] else {
            return false
        }
       
        return Set(requiredSchemes).isSubset(of: Set(schemes))
    }
}

struct RequiredPlistValue: ShareOutletRequirementProtocol
{
    
    let requiredKey: String
    let requiredValue: String
    public init(requiredKey: String, requiredValue: String)
    {
        self.requiredKey = requiredKey
        self.requiredValue = requiredValue
    }
    
    func met(plist: [String : Any?]) -> Bool
    {
        guard let stringValue = plist[self.requiredKey] as? String else {
            return false
        }
        return stringValue == self.requiredValue
    }
    
}

class RequiredConfigurationValue: ShareOutletRequirementProtocol
{
    func met(plist: [String : Any?]) -> Bool {
        false
    }
    
    let requiredConfigurationValue: String
    public init(requiredConfigurationValue: String)
    {
        self.requiredConfigurationValue = requiredConfigurationValue
    }
}

class RequiredPlistNonNil: ShareOutletRequirementProtocol
{
    let requiredKey: String
    let defaultValue: String?
    public init(requiredKey: String, defaultValue: String? = nil)
    {
        self.requiredKey = requiredKey
        self.defaultValue = defaultValue
    }
    
    func met(plist: [String : Any?]) -> Bool
    {
        return plist[self.requiredKey] != nil
    }
    
}


class Requirements: ShareOutletRequirementProtocol {

    let requirements:[ShareOutletRequirementProtocol]
    
    public init(requirements: [ShareOutletRequirementProtocol])
    {
        self.requirements = requirements
    }
    
    func met(plist: [String : Any?]) -> Bool
    {
        for req in requirements {
            let met = req.met(plist: plist)
            if !met {
                return false
            }
        }
        return true
    }
}

class SnapchatRequirements: Requirements
{
    public init(snapchatClientKey: String?)
    {
        guard let snapchatClientKey = snapchatClientKey else {
            super.init(requirements: [
                RequiredConfigurationValue(requiredConfigurationValue: "snapchatClientKey")
            ])
            return
        }
        super.init(requirements: [
            RequiredPlistValue(requiredKey: "SCSDKClientId", requiredValue: snapchatClientKey),
            RequiredApplicationQuerySchemes(requiredSchemes: ["snapchat"])
        ])
    }
}

class PhotoRequirement: RequiredPlistNonNil
{
    public init()
    {
        super.init(requiredKey: "NSPhotoLibraryUsageDescription")
    }
}


class NoRequirements: Requirements
{
    public init()
    {
        super.init(requirements: [])
    }
}

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


class InstagramFeedRequirements: Requirements
{
    public init()
    {
        super.init(requirements: [
            PhotoRequirement(),
            RequiredApplicationQuerySchemes(requiredSchemes: [
                "instagram",
            ]),
        ])
    }
}


class InstgramStoriesRequirements: Requirements
{
    public init()
    {
        super.init(requirements: [
            RequiredApplicationQuerySchemes(requiredSchemes: [
                "instagram-stories",
            ])
        ])
    }
}

class TwitterRequirements: Requirements
{
    public init()
    {
        super.init(requirements: [
            RequiredApplicationQuerySchemes(requiredSchemes: [
                "twitter",
            ])
        ])
    }
}
