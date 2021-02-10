//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/6/21.
//


import XCTest
@testable import ShareThatTo

final class DeviceTests: XCTestCase {
    func testDeviceOSVersion() {
        let device = Device()
        let osVersion = device.osVersion
        XCTAssert(osVersion != "")
        
        let range = NSRange(location: 0, length: osVersion.utf16.count)
        let regex = try! NSRegularExpression(pattern: "\\d+\\.\\d+\\.\\d+")
        XCTAssert(regex.firstMatch(in: osVersion, options: [], range: range) != nil)
    }
    
    func testDeviceDescription() {
        let device = Device()
        let output = device.description()
        let keys = [
            "os_version",
            "app_version",
            "manufacturer",
            "platform",
        ]
        
        // Make sure the output has all the right keys
        XCTAssertEqual(output.count, keys.count)
        
        // Loop all keys and make sure they are there
        for key in keys {
            XCTAssert(output[key] != nil)
        }
    }

    static var allTests = [
        ("testDeviceDescription", testDeviceDescription),
        ("testDeviceOSVersion", testDeviceOSVersion),
    ]
}
