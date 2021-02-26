//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/3/21.
//

import UIKit
import Foundation

internal class Network
{
    internal var userId:String?
    internal static let shared = Network()
    
    internal let baseURL: URL
    internal let analyticsBaseURL: URL
    internal let urlSession: URLSession
    private let authenticationDatastore: AuthenticationDatastoreProtocol
    private let contribDatastore: ContribDatastoreProtocol
    
    
    public init(
        urlSession: URLSession = URLSession(configuration: .ephemeral),
        authenticationDatastore: AuthenticationDatastoreProtocol = Datastore.shared.authenticationDatastore,
        contribDatastore: ContribDatastoreProtocol = Datastore.shared.contribDatastore,
        baseURL: URL = URL(string: "https://sharethatto-sdk.herokuapp.com/v1/api/sdk/")!,
//        baseURL: URL = URL(string: "http://10.0.0.92:3000/v1/api/sdk/")!,
        analyticsBaseURL: URL = URL(string: "https://collector.sharethatto.com/v1/events")!
    )
    {
        self.urlSession = (urlSession)
        self.authenticationDatastore = authenticationDatastore
        self.contribDatastore = contribDatastore
        self.baseURL = baseURL
        self.analyticsBaseURL = analyticsBaseURL
    }
    
    internal func log(message: String)
    {
        print(message)
    }
}

struct EmptyResponse: Decodable {}

extension Network
{
    enum Error: LocalizedError
    {
        case unknown
        case notAuthenticated
        case decoding
        
        var errorDescription: String? {
            switch self
            {
            case .unknown: return NSLocalizedString("An unknown error occurred.", comment: "")
            case .notAuthenticated: return NSLocalizedString("Unauthorized.", comment: "")
            case .decoding: return NSLocalizedString("Decoding error.", comment: "")
            }
        }
    }
}



/*
 extension JSONDecoder.DateDecodingStrategy {
     static let iso8601withFractionalSeconds = custom {
         let container = try $0.singleValueContainer()
         let string = try container.decode(String.self)
         guard let date = Formatter.iso8601withFractionalSeconds.date(from: string) else {
             throw DecodingError.dataCorruptedError(in: container,
                   debugDescription: "Invalid date: " + string)
         }
         return date
     }
 }
 */

//MARK: Private extension for actually making requests

extension Network
{
    func send<ResponseType: Decodable>(_ request: URLRequest, completion: @escaping (Result<ResponseType, Swift.Error>) -> Void)
    {
        var request = request
        guard let unwrappedApiKey = authenticationDatastore.apiKey  else { return completion(.failure(Error.notAuthenticated))  }
        request.setValue("Bearer " + unwrappedApiKey, forHTTPHeaderField:  "Authorization")
        if let unwrappedUserId = contribDatastore.userId {
            request.setValue(unwrappedUserId, forHTTPHeaderField: "X-Contrib-UserId")
        }
        
        
        let task = self.urlSession.dataTask(with: request) { (data, response, error) in
            do
            {
                guard let unWrappedData = data else { return completion(.failure(error ?? Error.unknown))}
                
                if let response = response as? HTTPURLResponse, response.statusCode == 401
                {

                    return completion(.failure(Error.notAuthenticated))
                }
                // TODO: Remove this
//                print(String(data: unWrappedData, encoding: .utf8))
                self.log(message: String(data: unWrappedData, encoding: .utf8) ?? "")
                let response = try JSONDecoder().decode(ResponseType.self, from: unWrappedData)
                completion(.success(response))
            }
            catch let error
            {
                completion(.failure(Error.decoding))
            }
        }
        task.resume()
    }
}
