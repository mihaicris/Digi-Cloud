//
//  DigiClient.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 26/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import Foundation

// Singleton class for DIGI Client

class DigiClient {
    
    // MARK: - Properties
    var token: String!
    var currentMount: String!
    var currentPath: [String] = []
    
    // Shared Session
    var session = URLSession.shared
    
    // MARK: - Initializers
    init() {}
    
    // MARK: - Errors
    enum NetworkingError: Error {
        case get(String)
        case post(String)
        case del(String)
        case wrongStatus(String)
        case data(String)
    }
    enum JSONError: Error {
        case parce(String)
    }
    enum Authentication: Error {
        case login(String)
    }
    
    // MAKR: - Shared instance
    class func shared() -> DigiClient {
        struct Singleton {
            static var shared = DigiClient()
        }
        return Singleton.shared
    }
    
    // MARK: - GET 
    func networkTask(requestType: String,
                     method: String,
                     headers: [String: String]?,
                     json: [String: String]?,
                     parameters: [String: Any]?,
                     completionHandler: @escaping (_ data: Any?, _ error: Error?) -> Void)
    {
        
        /* 1. Build the URL, Configure the request */
        let url = self.getURL(method: method, parameters: parameters)
    
        var request = self.getURLRequest(url: url, requestType: requestType, headers: headers)
        
        // add json object to request
        if let json = json {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: json, options: [])
            } catch {
                completionHandler(nil, JSONError.parce("Could not convert json into data!"))
            }
        }

        /* 2. Make the request */
        let task = session.dataTask(with: request) {
            (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                completionHandler(nil, NetworkingError.get("There was an error with your request: \(error)"))
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completionHandler(nil, NetworkingError.wrongStatus("Your request returned a status code other than 2xx!"))
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                completionHandler(nil, NetworkingError.data("No data was returned by the request!"))
                return
            }
            
        /* 3. Parse the data and use the data (happens in completion handler) */
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                completionHandler(json, nil)
            } catch {
                completionHandler(nil, JSONError.parce("Could not parse the data as JSON"))
            }
        }
        
        /* 4. Start the request */
        task.resume()
    }
    
    // MARK: - Helper Functions
    
    func getURL(method: String, parameters: [String: Any]?) -> URL {
        var components = URLComponents()
        components.scheme = API.Scheme
        components.host = API.Host
        components.path = method
        
        if let parameters = parameters {
            components.queryItems = [URLQueryItem]()
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
            components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        }
        return components.url!
    }
    
    private func getURLRequest(url: URL, requestType: String, headers: [String: String]?) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = requestType
        
        if let headers = headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        return request
    }
}

