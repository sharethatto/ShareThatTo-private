//
//  File.swift
//  
//
//  Created by Justin Hilliard on 2/28/21.
//

import Foundation

struct ContentHelper {
    static func createFileURL(filename: String, filenameExt: String) -> URL? {
        // Use the CachesDirectory so the rendered video file sticks around as long as we need it to.
        // Using the CachesDirectory ensures the file won't be included in a backup of the app.
        let fileManager = FileManager.default
        if let cachesDirectoryUrl = try? fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true) {
            let shareThatToDirectory = cachesDirectoryUrl.appendingPathComponent("ShareThatTo")
            let fileURLDirectory = shareThatToDirectory.appendingPathComponent(filename).appendingPathExtension(filenameExt)
            if !fileManager.fileExists(atPath: fileURLDirectory.path) {
                do {
                    try fileManager.createDirectory(atPath: shareThatToDirectory.path, withIntermediateDirectories: true, attributes: nil)
                    return fileURLDirectory
                } catch {
                    Logger.log(message: "Cannot create Share That To Folder in caches directory. \(error.localizedDescription)")
                    return nil
                }
            } else {
                do {
                    try fileManager.removeItem(atPath: fileURLDirectory.path)
                    try fileManager.createDirectory(atPath: fileURLDirectory.path, withIntermediateDirectories: true, attributes: nil)
                    return fileURLDirectory
                } catch {
                    Logger.log(message: "Cannot create Share That To Folder in caches directory. \(error.localizedDescription)")
                    return nil
                }
            }
        } else {
            Logger.log(message: "Cannot get cachesDirectoryUrl")
            return nil
        }
    }
    
}
