//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/3/21.
//

import UIKit
import Foundation

public class Network
{
    public var apiKey:String?
    public var userId:String?
    public static let shared = Network()
    private let session = URLSession(configuration: .ephemeral)
    private let baseURL = URL(string: "https://screenshot-api.sharethatto.com/api/v1")!
    
    private init()
    {
    }
}

extension Network
{
    enum Error: LocalizedError
    {
        case unknown
        case notAuthenticated
        
        var errorDescription: String? {
            switch self
            {
            case .unknown: return NSLocalizedString("An unknown error occurred.", comment: "")
            case .notAuthenticated: return NSLocalizedString("Unauthorized.", comment: "")
            }
        }
    }
}

//
//func uploadImage(image: UIImage, completion: @escaping (Result<Void, Swift.Error>) -> Void)
//{
//    // We don't know where we're sending the image event until we hear back from the server
//    guard let upload = screenshotResponse.upload else { return completion(.failure(Error.unknown)) }
//    guard let uploadURL = URL(string: upload.signed_url) else { return completion(.failure(Error.unknown)) }
//    
//    var request = URLRequest(url: uploadURL)
//    request.httpMethod = "PUT"
//    request.timeoutInterval = 30.0
//    
//    // We have to support custom headers for image upload
//    for(key, value) in upload.headers {
//        request.addValue(value, forHTTPHeaderField: key)
//    }
//    request.httpBody = image.pngData()
//    
//    let task = self.session.dataTask(with: request) { (data, response, error) in
//        completion(.success(Void()))
//    }
//    task.resume()
//}
