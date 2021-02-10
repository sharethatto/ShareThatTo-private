//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/6/21.
//

import UIKit
import Foundation

class Device
{
    
    internal func description() -> [String:Any] {
        return [
            "app_version": appVersion,
            "os_version": osVersion,
            "manufacturer": manufacturer,
            "platform": platform,
        ]
    }
    
    private let appVersionOnce:Once<Device, String> = Once { myself in  Bundle.main.releaseVersionNumber }
    var appVersion: String {
        get { self.appVersionOnce.once(self, defaultValue: "") }
    }
    
    private let osVersionOnce:Once<Device, String> = Once { myself in
        let systemVersion = ProcessInfo.processInfo.operatingSystemVersion
        return String(format: "%ld.%ld.%ld", arguments: [systemVersion.majorVersion, systemVersion.minorVersion, systemVersion.patchVersion])
    }
    var osVersion: String {
        get { self.osVersionOnce.once(self, defaultValue: "") }
    }
    
    var manufacturer: String {
        get { "Apple" }
    }
    
    private let platformOnce:Once<Device, String> = Once { myself in
        return UIDevice.modelName
    }
    var platform: String {
        get { platformOnce.once(self, defaultValue: "") }
    }
}
