//
//  File.swift
//  
//
//  Created by Brian Anglin on 3/3/21.
//

import Foundation
public protocol ShareOutletRequirementProtocol
{
    func met(plist: [String:Any?]) -> Bool
}

public struct RequiredApplicationQuerySchemes: ShareOutletRequirementProtocol
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
}

public struct RequiredCFBundleURLSchemes: ShareOutletRequirementProtocol
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

public struct RequiredPlistValue: ShareOutletRequirementProtocol
{
    
    let requiredKey: String
    let requiredValue: String
    public init(requiredKey: String, requiredValue: String)
    {
        self.requiredKey = requiredKey
        self.requiredValue = requiredValue
    }
    
    public func met(plist: [String : Any?]) -> Bool
    {
        guard let stringValue = plist[self.requiredKey] as? String else {
            return false
        }
        return stringValue == self.requiredValue
    }
    
}

public class RequiredConfigurationValue: ShareOutletRequirementProtocol
{
    public func met(plist: [String : Any?]) -> Bool {
        false
    }
    
    let requiredConfigurationValue: String
    public init(requiredConfigurationValue: String)
    {
        self.requiredConfigurationValue = requiredConfigurationValue
    }
}

public class RequiredPlistNonNil: ShareOutletRequirementProtocol
{
    let requiredKey: String
    let defaultValue: String?
    public init(requiredKey: String, defaultValue: String? = nil)
    {
        self.requiredKey = requiredKey
        self.defaultValue = defaultValue
    }
    
    public func met(plist: [String : Any?]) -> Bool
    {
        return plist[self.requiredKey] != nil
    }
    
}

open class Requirements: ShareOutletRequirementProtocol
{

    let requirements:[ShareOutletRequirementProtocol]
    
    public init(requirements: [ShareOutletRequirementProtocol])
    {
        self.requirements = requirements
    }
    
    public func met(plist: [String : Any?]) -> Bool
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
