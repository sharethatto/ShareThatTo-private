//
//  Logger.swift
//  UCGCreator
//
//  Created by Justin Hilliard on 2/23/21.
//

import Foundation

struct UGCLogger {
    static func log(message: String)
    {
        print("[ShareThatTo] [UGCGenerator] \(message)")
    }
}

struct UGCDurationLogger
{
    private let startTime: Date
    private let prefix: String
    private init(prefix: String)
    {
        self.startTime = Date()
        self.prefix = prefix
    }
    
    public static func begin(prefix: String = "") -> UGCDurationLogger
    {
        print("[ShareThatTo] \(prefix) Beginning operation")
        return UGCDurationLogger(prefix: prefix)
    }
    
    public func finish()
    {
        print("[ShareThatTo] \(prefix) Finished: \(Date().timeIntervalSince(self.startTime) * 1000))")
    }
}
