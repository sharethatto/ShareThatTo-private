//
//  File.swift
//
//
//  Created by Brian Anglin on 2/6/21.
//

import Foundation

import XCTest
@testable import ShareThatTo

final class OutletsTests: XCTestCase {
        
    func testOutletsHaveImages()
    {
        
        for outlet in ShareOutlets.availableOutlets
        {

            
            let buttonImage = outlet.buttonImage()
            XCTAssertNotNil(buttonImage)
        }
    
    }

    static var allTests = [
        ("testOutletsHaveImages", testOutletsHaveImages),
    ]
}

