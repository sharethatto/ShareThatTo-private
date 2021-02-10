//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/7/21.
//

import XCTest
@testable import ShareThatTo

final class InstrumenterTests: XCTestCase {
    func testInstrumentation()
    {
        Instrumeter.shared.log(key: "error", payload: [
            "localization":"abc"
        ])
        Instrumeter.shared.track("hi")
    }
    
 

    static var allTests = [
        ("testInstrumentation", testInstrumentation),
    ]
}
