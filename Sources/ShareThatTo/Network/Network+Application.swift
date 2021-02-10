//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/9/21.
//

import Foundation

struct ApplicationResponse: Decodable
{
    var cta_link: String?
}

protocol NetworkApplicationProtocol
{
    func application(completion: @escaping (Result<ApplicationResponse, Swift.Error>) -> Void)
}

extension Network: NetworkApplicationProtocol
{
    func application(completion: @escaping (Result<ApplicationResponse, Swift.Error>) -> Void)
       {
           let components = URLComponents(string: "/api/application")!
           let requestURL = components.url(relativeTo: baseURL)!
           var request = URLRequest(url: requestURL)
           request.httpMethod = "GET"
           request.setValue("application/json", forHTTPHeaderField: "Content-Type")
           
           self.send(request)  { (result: Result<ApplicationResponse, Swift.Error>) in
               switch result
               {
               case .failure(let error): completion(.failure(error))
               case .success(let response):
                   completion(.success((response)))
               }
           }
       }
}
