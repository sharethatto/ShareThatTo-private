//
//  File.swift
//  
//
//  Created by Brian Anglin on 3/27/21.
//

import Foundation
internal class ResourceLoader
{
    public static let shared = ResourceLoader()
    
    lazy var cache: URLCache = {
        let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let diskCacheURL = cachesURL.appendingPathComponent("ShareThatToDownloadCache")
        if #available(iOS 13.0, *) {
            return URLCache(memoryCapacity: 10_000_000, diskCapacity: 1_00_000_000, directory: diskCacheURL)
        } else {
            return URLCache(memoryCapacity: 10_000_000, diskCapacity: 1_00_000_000, diskPath: diskCacheURL.absoluteString)
        }
    }()
    
    lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.urlCache = cache
        config.timeoutIntervalForRequest = 15.0
        config.timeoutIntervalForResource = 15.0
        return URLSession(configuration: config)
    }()

    lazy var documentsDirectory: URL = {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let resourceDocumentsDirectory = documentsDirectory.appendingPathComponent("ShareThatToResources")
        return resourceDocumentsDirectory
    }()
    
    private init()
    {
    }
}

extension ResourceLoader
{
    enum Error: LocalizedError
    {
        case unknown
        case notFound
        case serverError
        
        var errorDescription: String? {
            switch self
            {
            case .unknown: return NSLocalizedString("An unknown error occurred.", comment: "")
            case .notFound: return NSLocalizedString("Resource not found.", comment: "")
            case .serverError: return NSLocalizedString("Server error", comment: "")
            }
        }
    }
}

extension ResourceLoader
{
    func fetch(url: URL, directoryPrefix: String? = nil, completion: @escaping (Result<URL, Swift.Error>) -> Void)
    {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        send(request, directoryPrefix: directoryPrefix, completion: completion)
    }
    
    // This URL may go away at any time...
    func send(_ request: URLRequest, directoryPrefix: String? = nil, completion: @escaping (Result<URL, Swift.Error>) -> Void)
    {
        
        let durationLogger =  DurationLogger.begin(prefix: "[ResourceLoader] fetch")
        Logger.shareThatToDebug(string: "Requesting url: \(request.url)")
        var request = request
        let task = self.urlSession.downloadTask(with: request) { (url, response, error) in
            durationLogger.finish()
            
            // If there was an error, return
            if let error = error
            {
                return completion(.failure(error))
            }
            
            if let urlResponse = response as? HTTPURLResponse
            {
                if urlResponse.statusCode >= 400 && urlResponse.statusCode < 500
                {
                    return completion(.failure(Error.notFound))
                }
                if urlResponse.statusCode >= 500
                {
                    return completion(.failure(Error.serverError))
                }
            }
            
            if let response = response, let url = url,
                self.cache.cachedResponse(for: request) == nil,
                let data = try? Data(contentsOf: url, options: [.mappedIfSafe])
            {
                self.cache.storeCachedResponse(CachedURLResponse(response: response, data: data), for: request)
            }
            

            guard let tempURL = url else { return completion(.failure(Error.notFound)) }
            self.handleDownload(request: request, url: tempURL, directoryPrefix: directoryPrefix, completion: completion)
        }
        task.resume()
    }
    
    private func handleDownload(request: URLRequest, url: URL, directoryPrefix: String? = nil, completion: @escaping (Result<URL, Swift.Error>) -> Void)
    {
        // Optionally add a sub-directory
        var targetURL = self.documentsDirectory
        if let directoryPrefix = directoryPrefix {
            targetURL = targetURL.appendingPathComponent(directoryPrefix)
        }
        
        // Figure out a filename. Ideally it will be the md5 of the original url, if not we'll use the tempURL's filename
        var filename: String =  url.lastPathComponent
        if let requestURL = request.url
        {
            if  let md5filename = requestURL.absoluteString.hashed(.md5)
            {
                filename = md5filename + "." + requestURL.pathExtension
            }
        }
  
        
        targetURL = self.documentsDirectory.appendingPathComponent(filename)
        
        // Try and move the file to the correct place
        do {
            let directoryPath = targetURL.deletingLastPathComponent().path
            if !FileManager.default.fileExists(atPath: directoryPath)
            {
                try FileManager.default.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
            }
            let moveResult = try FileManager.default.replaceItemAt(targetURL, withItemAt: url)
            guard let unwrappedMoveResult = moveResult else { return completion(.failure(Error.unknown)) }
            completion(.success(unwrappedMoveResult))
        } catch let error {
            completion(.failure(error))
        }
    }
}
