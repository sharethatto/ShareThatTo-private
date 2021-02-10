//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/7/21.
//

import UIKit
import Foundation
class TemporaryDirectoryHelper
{
    internal static func createTempDirectory(directoryName: String?) -> URL?
    {
        let directoryName: String = directoryName ?? UUID().uuidString
        guard let tempDirectoryTemplate = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(directoryName) else { return nil }
        let fileManager = FileManager.default

        do {
            try fileManager.createDirectory(at: tempDirectoryTemplate, withIntermediateDirectories: true, attributes: nil)
            return tempDirectoryTemplate
        } catch  {
            return nil
        }
    }
}
