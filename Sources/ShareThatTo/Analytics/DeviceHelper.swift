//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/6/21.
//

import UIKit
import Foundation


struct Device: Codable {
    var app_version: String
    var os_version: String
    var platform: String
    var vendor_id: String
}

class DeviceHelper
{
    internal static func device() -> Device {
        return Device(
            app_version: shared.appVersion,
            os_version: shared.osVersion,
            platform: shared.platform,
            vendor_id: shared.vendorId
        )
    }
    
    private static let shared = DeviceHelper()
    
    private let appVersionOnce:Once<DeviceHelper, String> = Once { myself in  Bundle.main.releaseVersionNumber }
    var appVersion: String {
        get { self.appVersionOnce.once(self, defaultValue: "") }
    }
    
    private let osVersionOnce:Once<DeviceHelper, String> = Once { myself in
        let systemVersion = ProcessInfo.processInfo.operatingSystemVersion
        return String(format: "%ld.%ld.%ld", arguments: [systemVersion.majorVersion, systemVersion.minorVersion, systemVersion.patchVersion])
    }
    var osVersion: String {
        get { self.osVersionOnce.once(self, defaultValue: "") }
    }
    
    private let platformOnce:Once<DeviceHelper, String> = Once { myself in
        return UIDevice.modelName
    }
    var platform: String {
        get { platformOnce.once(self, defaultValue: "") }
    }
    
    private let vendorIdOnce:Once<DeviceHelper, String> = Once { myself in
        return UIDevice.current.identifierForVendor?.uuidString
    }
    var vendorId: String {
        get { vendorIdOnce.once(self, defaultValue: "") }
    }
}
