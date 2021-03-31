//
//  File.swift
//  
//
//  Created by Brian Anglin on 3/28/21.
//

import Foundation

struct ContextResponse: Decodable
{
    var code: String
//    var token: String 
}

protocol NetworkDebugProtocol
{
    func uploadContext(context: UGCContext, completion: @escaping (Result<ContextResponse, Swift.Error>) -> Void)
}

extension Network: NetworkDebugProtocol
{
    func uploadContext(context: UGCContext, completion: @escaping (Result<ContextResponse, Swift.Error>) -> Void)
    {
       let components = URLComponents(string: "debug/context")!
       let requestURL = components.url(relativeTo: baseURL)!
       var request = URLRequest(url: requestURL)
       request.httpMethod = "PUT"
       request.setValue("application/json", forHTTPHeaderField: "Content-Type")
       
       // Bail if we can't encode
       do {
           request.httpBody = try JSONEncoder().encode(context)
        
       } catch {
           return completion(.failure(Error.unknown))
       }
       
       self.send(request)  { (result: Result<ContextResponse, Swift.Error>) in
           switch result
           {
           case .failure(let error):
            Logger.shareThatToDebug(string: "[network POST /debug/context] - failure", error: error, documentation: .unexpecteError)
            completion(.failure(error))
           case .success(let response):
            completion(.success(response))
           }
       }
    }
}

