//
//  File.swift
//
//
//  Created by Brian Anglin on 2/9/21.
//

import Foundation

protocol NetworkAnalyticsProtocol
{
    func batchUploadEvents(events: [WrappedAnalyticsEvent], completion: @escaping (Result<Void, Swift.Error>) -> Void)
}

extension Network: NetworkAnalyticsProtocol
{
    func batchUploadEvents(events: [WrappedAnalyticsEvent], completion: @escaping (Result<Void, Swift.Error>) -> Void)
       {
           let components = URLComponents(string: "/v1/events")!
           let requestURL = components.url(relativeTo: analyticsBaseURL)!
           var request = URLRequest(url: requestURL)
           request.httpMethod = "POST"
           request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
            // Bail if we can't encode
            struct BatchEvents: Encodable {
                var events: [WrappedAnalyticsEvent]
            }
            do {
                request.httpBody = try JSONEncoder().encode(BatchEvents(events: events))
            } catch {
                return completion(.failure(Error.unknown))
            }
           
           self.send(request)  { (result: Result<EmptyResponse, Swift.Error>) in
               switch result
               {
               case .failure(let error): completion(.failure(error))
               case .success:
                   completion(.success(Void()))
               }
           }
       }
}
