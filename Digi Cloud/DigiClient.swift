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
    var token: String? = nil
    
    // Shared Session
    var session: URLSession = URLSession.shared
    
    // MARK: - Initializers
    init() {}
    
    // MARK: - Errors
    enum NetworkingError: Error {
        case get(String)
        case post(String)
        case delete(String)
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
    class func sharedInstance() -> DigiClient {
        struct Singleton {
            static var sharedInstance = DigiClient()
        }
        return Singleton.sharedInstance
    }
    
    // MARK: - GET 
    func networkTask(type: String,
                     method: String,
                     headers: [String: String]?,
                     json: [String: String],
                     parameters: [String: Any]?,
                     completionHandlerForGET: @escaping (_ result: Any?, _ error: Error?) -> Void) -> URLSessionDataTask {
        
        /* 1. Build the URL, Configure the request */
        let url = getURL(method: method, parameters: parameters)
        
        print(url.absoluteString)
        print(json)
        
        var request = getURLRequest(url: url, headers: headers)
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: json, options: [])
        } catch {
            print("jsonBody is empty")
            completionHandlerForGET(nil, JSONError.parce("jsonBody is empty"))
        }
        
        /* 2. Make the request */
        let task = session.dataTask(with: request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                completionHandlerForGET(nil, NetworkingError.get("There was an error with your request: \(error)"))
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completionHandlerForGET(nil, NetworkingError.wrongStatus("Your request returned a status code other than 2xx!"))
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                completionHandlerForGET(nil, NetworkingError.data("No data was returned by the request!"))
                return
            }
            
        /* 3. Parse the data and use the data (happens in completion handler) */
            
            do {
                let parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                completionHandlerForGET(parsedResult, nil)
            } catch {
                completionHandlerForGET(nil, JSONError.parce("Could not parse the data as JSON"))
            }
            
        }
        
        /* 4. Start the request */
        task.resume()
        
        return task
    }
    
    private func getURL(method: String, parameters: [String: Any]?) -> URL {
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
        }
        return components.url!
    }
    
    private func getURLRequest(url: URL, headers: [String: String]?) -> URLRequest {
        var request = URLRequest(url: url)
        
        if let headers = headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        return request
    }

}

