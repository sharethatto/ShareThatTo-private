//
//  Logger.swift
//  UCGCreator
//
//  Created by Justin Hilliard on 2/23/21.
//

import Foundation

struct Logger{
    static func log(message: String){
        print(message)
    }
}


struct DurationLogger
{
    private let startTime: Date
    private let prefix: String
    private init(prefix: String)
    {
        self.startTime = Date()
        self.prefix = prefix
    }
    
    public static func begin(prefix: String = "") -> DurationLogger
    {
        print("\(prefix) Beginning operation")
        return DurationLogger(prefix: prefix)
    }
    
    public func finish()
    {
        print("\(prefix) Finished: \(Date().timeIntervalSince(self.startTime) * 1000))")
    }
}
