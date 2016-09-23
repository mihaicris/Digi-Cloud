//
//  Constants.swift
//  test
//
//  Created by Mihai Cristescu on 15/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import Foundation

struct Utils {
    
    static func getRequestForAuthentication(email: String, password: String) -> URLRequest {
        
        // Prepare url from url components
        var components = URLComponents()
        components.scheme   = API.Scheme
        components.host     = API.Host
        components.path     = API.Paths.Token
        
        // Create request with headers for authentication
        var request = URLRequest(url: components.url!)
        request.addValue(email,     forHTTPHeaderField: "X-Koofr-Email")
        request.addValue(password,  forHTTPHeaderField: "X-Koofr-Password")
        
        return request
    }
    
    static func getURLFromParameters(path: String, parameters: [String: Any]?) -> URL {
        var components      = URLComponents()
        components.scheme   = API.Scheme
        components.host     = API.Host
        components.path     = path

        if parameters != nil {
            components.queryItems = [URLQueryItem]()
            for (key, value) in parameters! {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }
        return components.url!
    }
    
    static func getURLForMountContent(mount: String, path: String) -> URL {
        var components = URLComponents()
        components.scheme = API.Scheme
        components.host = API.Host
        components.path = API.Paths.Mounts + "/" + mount + "/files/list"
        components.queryItems = [URLQueryItem(name: "path", value: path)]
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        return components.url!
    }
}
