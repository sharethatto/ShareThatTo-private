//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/5/21.
//

import Foundation


// Configurable Strategy
struct DirectUpload: Codable {
    var url: URL
    var headers:[String:String]
}
struct Configurable: Decodable {
    var direct_upload: DirectUpload
}

// Returned from the /share route
struct UploadPlan: Decodable {
    enum Strategy: String, Decodable {
        case unknown = ""
        case configurable = "configurable"
    }
    var strategy: Strategy

    var configurable: Configurable?
}


// A request for a plan on how to upload this content
struct UploadPlanRequest: Codable {
    var byte_size: Int
    var checksum: String
    var content_type: String
}


protocol NetworkUploadProtocol {
    func upload(plan: UploadPlan, data: Data,  completion: @escaping (Result<Void, Swift.Error>) -> Void)
    func uploadWithConfigurable(configurable: Configurable, data: Data, completion: @escaping (Result<Void, Swift.Error>) -> Void)
}

extension Network: NetworkUploadProtocol {
    
    internal func upload(plan: UploadPlan, data: Data,  completion: @escaping (Result<Void, Swift.Error>) -> Void)
    {
        switch plan.strategy {
        case .configurable:
            guard  let configurable = plan.configurable else { return completion(.failure(Error.unknown)) }
            uploadWithConfigurable(configurable: configurable, data: data, completion: completion)
        default:
            return completion(.failure(Error.unknown))
        }
    }
    
    internal func uploadWithConfigurable(configurable: Configurable, data: Data, completion: @escaping (Result<Void, Swift.Error>) -> Void)
    {
        // We don't know where we're sending the image event until we hear back from the server
        var request = URLRequest(url: configurable.direct_upload.url)
        request.httpMethod = "PUT"
        request.timeoutInterval = 30.0
        
        // We have to support custom headers for image upload
        for(key, value) in configurable.direct_upload.headers {
            request.addValue(value, forHTTPHeaderField: key)
        }
        request.httpBody = data
        
        let task = self.urlSession.dataTask(with: request) { (data, response, error) in
            completion(.success(Void()))
        }
        task.resume()
    }
}
