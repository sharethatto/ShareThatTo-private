//
//  File.swift
//  
//
//  Created by Brian Anglin on 3/3/21.
//

import Foundation
struct DurationLogger
{
    private let originalStartTime: Date
    private var startTime: Date
    private let prefix: String
    private init(prefix: String)
    {
        self.startTime = Date()
        self.originalStartTime = Date()
        self.prefix = prefix
    }
    
    public static func begin(prefix: String = "") -> DurationLogger
    {
        print("[ShareThatTo] \(prefix) Beginning")
        return DurationLogger(prefix: prefix)
    }
    
    public mutating func trace(_ string: String)
    {
        print("[ShareThatTo] \(prefix) \(string) Trace: \(Date().timeIntervalSince(self.startTime) * 1000))")
        self.startTime = Date()
    }
    
    public func finish()
    {
        
        print("[ShareThatTo] \(prefix) Finished: \(Date().timeIntervalSince(self.startTime) * 1000) ( \(Date().timeIntervalSince(self.originalStartTime) * 1000) total) ")
    }
}
