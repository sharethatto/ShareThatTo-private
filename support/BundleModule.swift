//
//  File.swift
//  
//
//  Created by Brian Anglin on 3/14/21.
//

//import Foundation
import class Foundation.Bundle
//
private class BundleFinder {}

extension Foundation.Bundle {
    /// Returns the resource bundle associated with the current Swift module.
    static var module: Bundle = {
        let bundleName = "ShareThatTo_ShareThatToAssets"

        let candidates = [
            // Bundle should be present here when the package is linked into an App.
            Bundle.main.resourceURL,

            // Bundle should be present here when the package is linked into a framework.
            Bundle(for: BundleFinder.self).resourceURL,

            // For command-line tools.
            Bundle.main.bundleURL,
        ]

        for candidate in candidates {
            let bundlePath = candidate?.appendingPathComponent(bundleName + ".bundle")
            print("BundlePath: \(bundlePath)")
            if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }
        fatalError("unable to find bundle named ShareThatTo_ShareThatTo")
    }()
}
