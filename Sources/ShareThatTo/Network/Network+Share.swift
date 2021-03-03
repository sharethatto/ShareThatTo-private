//
//  File.swift
//  
//
//  Created by Brian Anglin on 2/5/21.
//

import Foundation


/*
 * Share - POST /share
 * Share creates a share resource and provides a way to upload the backing resources
 */

// Request

struct ShareableRequest: Codable
{
   var title: String
   var shareable_type: String
}

struct ShareRequest: Codable
{
    var video_content: UploadPlanRequest
    var preview_image: UploadPlanRequest
    var shareable: ShareableRequest
}

// Response

struct Shareable: Codable
{
    var title: String
    var link: String
    var shareable_access_token: String
}

struct ShareResponse: Decodable
{
    var video_content: UploadPlan
    var preview_image: UploadPlan
    var shareable: Shareable
}

/*
 * Activate - POST /share/activate
 * Activate lets us know that a resource has been uploaed
 */

struct ActivateRequest: Codable {
    var video_content: Bool
    var preview_image: Bool
    var shareable_access_token: String
}

struct DeleteShareRequest: Codable {
    var shareable_access_token: String
}


protocol NetworkShareProtocol
{
    func shareRequest(share: ShareRequest, completion: @escaping (Result<ShareResponse, Swift.Error>) -> Void)
    func activateShare(activate: ActivateRequest, completion: @escaping (Result<EmptyResponse, Swift.Error>) -> Void)
    func deleteShare(delete: DeleteShareRequest, completion: @escaping (Result<EmptyResponse, Swift.Error>) -> Void)
}

extension Network: NetworkShareProtocol
{
    func shareRequest(share: ShareRequest, completion: @escaping (Result<ShareResponse, Swift.Error>) -> Void)
       {
           let components = URLComponents(string: "share")!
           let requestURL = components.url(relativeTo: baseURL)!
           var request = URLRequest(url: requestURL)
           request.httpMethod = "POST"
           request.setValue("application/json", forHTTPHeaderField: "Content-Type")
           
           // Bail if we can't encode
           do {
               request.httpBody = try JSONEncoder().encode(share)
            
           } catch {
               return completion(.failure(Error.unknown))
           }
           
           self.send(request)  { (result: Result<ShareResponse, Swift.Error>) in
               switch result
               {
               case .failure(let error):
                Logger.shareThatToDebug(string: "[network POST /share] - failure", error: error, documentation: .unexpecteError)
                completion(.failure(error))
               case .success(let response):
                   completion(.success(response))
               }
           }
        }


    func activateShare(activate: ActivateRequest, completion: @escaping (Result<EmptyResponse, Swift.Error>) -> Void)
    {
        let components = URLComponents(string: "share/activate")!
        let requestURL = components.url(relativeTo: baseURL)!
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Bail if we can't encode
        do {
            request.httpBody = try JSONEncoder().encode(activate)
        } catch {
            return completion(.failure(Error.unknown))
        }
        
        self.send(request)  { (result: Result<EmptyResponse, Swift.Error>) in
            switch result
            {
            case .failure(let error):
                Logger.shareThatToDebug(string: "[network POST /share/activate] - failure",  error:error, documentation: .unexpecteError)
                completion(.failure(error))
            case .success(let response):
                completion(.success((response)))
            }
        }
    }
    
    func deleteShare(delete: DeleteShareRequest, completion: @escaping (Result<EmptyResponse, Swift.Error>) -> Void)
    {
        let components = URLComponents(string: "share")!
        let requestURL = components.url(relativeTo: baseURL)!
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Bail if we can't encode
        do {
            request.httpBody = try JSONEncoder().encode(delete)
        } catch {
            return completion(.failure(Error.unknown))
        }
        
        self.send(request)  { (result: Result<EmptyResponse, Swift.Error>) in
            switch result
            {
            case .failure(let error):
                Logger.shareThatToDebug(string: "[network DELETE /share/activate] - failure", error:error, documentation: .unexpecteError)
                completion(.failure(error))
            case .success(let response):
                completion(.success((response)))
            }
        }
    }
}
    

