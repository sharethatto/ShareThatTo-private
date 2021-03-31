//
//  File.swift
//  
//
//  Created by Brian Anglin on 3/28/21.
//
import UIKit
import Foundation

struct JSONCodingKeys: CodingKey {
    var stringValue: String

    init?(stringValue: String) {
        self.stringValue = stringValue
    }

    var intValue: Int?

    init?(intValue: Int) {
        self.init(stringValue: "\(intValue)")
        self.intValue = intValue
    }
}


extension KeyedDecodingContainer {

    func decode(_ type: Dictionary<String, Any>.Type, forKey key: K) throws -> Dictionary<String, Any> {
        let container = try self.nestedContainer(keyedBy: JSONCodingKeys.self, forKey: key)
        return try container.decode(type)
    }

    func decodeIfPresent(_ type: Dictionary<String, Any>.Type, forKey key: K) throws -> Dictionary<String, Any>? {
        guard contains(key) else {
            return nil
        }
        guard try decodeNil(forKey: key) == false else {
            return nil
        }
        return try decode(type, forKey: key)
    }

    func decode(_ type: Array<Any>.Type, forKey key: K) throws -> Array<Any> {
        var container = try self.nestedUnkeyedContainer(forKey: key)
        return try container.decode(type)
    }

    func decodeIfPresent(_ type: Array<Any>.Type, forKey key: K) throws -> Array<Any>? {
        guard contains(key) else {
            return nil
        }
        guard try decodeNil(forKey: key) == false else {
            return nil
        }
        return try decode(type, forKey: key)
    }

    func decode(_ type: Dictionary<String, Any>.Type) throws -> Dictionary<String, Any> {
        var dictionary = Dictionary<String, Any>()

        for key in allKeys {
            if let boolValue = try? decode(Bool.self, forKey: key) {
                dictionary[key.stringValue] = boolValue
            } else if let stringValue = try? decode(String.self, forKey: key) {
                dictionary[key.stringValue] = stringValue
            } else if let intValue = try? decode(Int.self, forKey: key) {
                dictionary[key.stringValue] = intValue
            } else if let doubleValue = try? decode(Double.self, forKey: key) {
                dictionary[key.stringValue] = doubleValue
            } else if let nestedDictionary = try? decode(Dictionary<String, Any>.self, forKey: key) {
                dictionary[key.stringValue] = nestedDictionary
            } else if let nestedArray = try? decode(Array<Any>.self, forKey: key) {
                dictionary[key.stringValue] = nestedArray
            }
        }
        return dictionary
    }
}

extension UnkeyedDecodingContainer {

    mutating func decode(_ type: Array<Any>.Type) throws -> Array<Any> {
        var array: [Any] = []
        while isAtEnd == false {
            // See if the current value in the JSON array is `null` first and prevent infite recursion with nested arrays.
            if try decodeNil() {
                continue
            } else if let value = try? decode(Bool.self) {
                array.append(value)
            } else if let value = try? decode(Double.self) {
                array.append(value)
            } else if let value = try? decode(String.self) {
                array.append(value)
            } else if let nestedDictionary = try? decode(Dictionary<String, Any>.self) {
                array.append(nestedDictionary)
            } else if let nestedArray = try? decode(Array<Any>.self) {
                array.append(nestedArray)
            }
        }
        return array
    }

    mutating func decode(_ type: Dictionary<String, Any>.Type) throws -> Dictionary<String, Any> {

        let nestedContainer = try self.nestedContainer(keyedBy: JSONCodingKeys.self)
        return try nestedContainer.decode(type)
    }
}

struct DynamicKey: CodingKey {
    
    var stringValue: String

    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    var intValue: Int? { return nil }
    
    init?(intValue: Int) { return nil }
    
}

struct EncodableWrapper: Encodable {
    let wrapped: Encodable

    func encode(to encoder: Encoder) throws {
        try self.wrapped.encode(to: encoder)
    }
}

extension KeyedEncodingContainer where Key == DynamicKey {
    
    mutating func encodeDynamicKeyValues(withDictionary dictionary: [String : Any]) throws {
        for (key, value) in dictionary {
            let dynamicKey = DynamicKey(stringValue: key)!
            // Following won't work:
            // let v = value as Encodable
            // try propertiesContainer.encode(v, forKey: dynamicKey)
            // Therefore require explicitly casting to the supported value type:
            switch value {
            case let v as String: try encode(v, forKey: dynamicKey)
            case let v as Int: try encode(v, forKey: dynamicKey)
            case let v as Double: try encode(v, forKey: dynamicKey)
            case let v as Float: try encode(v, forKey: dynamicKey)
            case let v as Bool: try encode(v, forKey: dynamicKey)
            case let v as EncodableWrapper: try encode(v, forKey: dynamicKey)
            default: print("Type \(type(of: value)) not supported")
            }
        }
    }
}

/*
 
 
 String
 Number
 Dictionary
 Array
 Image -> Remote URL, Local URL, Literal
 Video -> Remote URL, Local URL
 
 */


// Contains all the things we need to build a UGC
public class UGCContext: Encodable
{
    private let tag: String
    public init(tag: String)
    {
        self.tag = tag
    }
    
    private var encodableSource: [String: Encodable] = [:]
    public func set(_ value: Encodable, forKey key: String)
    {
        encodableSource[key] = value
    }
    
    public func debug(on viewController: UIViewController)
    {
        let debugViewController = DebuggerViewController(context: self)
        viewController.present(debugViewController, animated: true)
    }
    
    public func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: DynamicKey.self)
        try container.encode(tag, forKey: DynamicKey.init(stringValue: "tag")!)
        
        var sources = container.nestedContainer(keyedBy: DynamicKey.self, forKey: DynamicKey.init(stringValue: "context")!)
        try sources.encodeDynamicKeyValues(withDictionary: encodableSource.mapValues(EncodableWrapper.init(wrapped:)))
    }
    
    public func context() -> [String:Any]
    {
        let json = JSONEncoder.init()
        do {
            let result = try json.encode(self)
            let responseDict = try JSONSerialization.jsonObject(with: result, options: .allowFragments) as! [String:Any]
            return responseDict["context"] as! [String:Any]
        } catch let error {
            print(error)
        }
        return [:]
    }
}
