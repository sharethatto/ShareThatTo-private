//
//  File.swift
//
//
//  Created by Brian Anglin on 2/9/21.
//

import Foundation

import XCTest
@testable import ShareThatTo

final class RequirementsTestsTests: XCTestCase {
    

    func testRequiredApplicationQuerySchemes()
    {
        var plist = ["LSApplicationQueriesSchemes": ["snapchat"]] as [String: Any?]
        let requirement = RequiredApplicationQuerySchemes(requiredSchemes: ["snapchat"])
        
        XCTAssert(requirement.met(plist: plist))
        
        plist = ["LSApplicationQueriesSchemes": ["not-snapchat"]]
        XCTAssertFalse(requirement.met(plist: plist))
    }
    
    func testRequiredPlistValue()
    {
        var plist = ["SomeKey": "SomeValue"] as [String: Any?]
        let requirement = RequiredPlistValue(requiredKey:"SomeKey", requiredValue:"SomeValue")
        XCTAssert(requirement.met(plist: plist))
        
        plist = ["SomeKey": "SomeOtherValue"]
        XCTAssertFalse(requirement.met(plist: plist))
        
        plist = [String: Any?]()
        XCTAssertFalse(requirement.met(plist: plist))
    }
    
    func testRrequiredPlistNonNil()
    {
        var plist = ["SomeKey": "SomeValue"] as [String: Any?]
        let requirement = RequiredPlistNonNil(requiredKey: "SomeKey")
        XCTAssert(requirement.met(plist: plist))
        
        plist = [String:Any?]()
        XCTAssertFalse(requirement.met(plist: plist))
    }

    func testPhotoRequirement()
    {
        var plist = ["NSPhotoLibraryUsageDescription": "SomeValue"] as [String: Any?]
        let requirement = PhotoRequirement()
        XCTAssert(requirement.met(plist: plist))
        
        plist = [String:Any?]()
        XCTAssertFalse(requirement.met(plist: plist))
    }
    
    func testCFBundleRequirement()
    {
        var plist = ["CFBundleURLTypes": [["CFBundleURLSchemes": ["fb123"]]]] as [String:[[String:[String]]]]
        let requirement = RequiredCFBundleURLSchemes(requiredSchemes: ["fb123"])
        
        XCTAssert(requirement.met(plist: plist))
        
        plist = ["CFBundleURLTypes": [["CFBundleURLSchemes": []]]] as [String:[[String:[String]]]]
        XCTAssertFalse(requirement.met(plist: plist))
    }
    
//    static var allTests = [
//        ("testRenderProducesThumbnailAndVideo", testRenderProducesThumbnailAndVideo),
//    ]
}
