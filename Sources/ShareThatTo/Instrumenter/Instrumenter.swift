//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/6/21.
//

import Foundation




/**
 * Instrumenter
 *
 * Understanding how something is working on a client, especially when there is a certain amount of flakyness
 * is really difficult. This will eventually be a place try and understand what is happening in the SDK
 */
internal class Instrumeter
{
    internal static let shared = Instrumeter()
    
    public func log(key: String, payload: Codable)
    {
        print(now(), key, device.description(), payload)
    }
    
    public func track(_ message: String, file: String = #file, function: String = #function, line: Int = #line )
    {
        print("\(message) called from \(function) \(file):\(line)")
    }
    
    public func instrument<T>(context: Context, name: String, file: String = #file, function: String = #function, line: Int = #line, completion: (@escaping (T) -> Void)) -> (T) -> Void
    {
        // When called start the timer
        let begin = Date()
        log(key: "called from \(function) \(file):\(line)", payload: [:] as [String:String])
        func newCompletion(result: T) -> Void
        {
            track(dateFormatter.string(from: Date()))
            completion(result)
        }
        return newCompletion
    }
    
    //MARK - Private
    
    private var device = Device()
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
    
    private func now() -> String
    {
        return dateFormatter.string(from: Date())
    }
}



