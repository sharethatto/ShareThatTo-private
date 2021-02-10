//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/9/21.
//

import Foundation

class TestHelpers {}

extension TestHelpers
{
    static var fixtureBundle: Bundle { get {
        let bundlePath = Bundle(for: NetworkApplicationTests.self).bundlePath + "/ShareThatTo_ShareThatToTests.bundle/Fixtures"
        let bundle = Bundle(path: bundlePath)!
        return bundle
    }}

}
