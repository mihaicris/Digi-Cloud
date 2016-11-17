//
//  DigiClient.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 26/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

// Singleton class for DIGI Client

final class DigiClient {

    // MARK: - Properties
    var token: String!
    var currentMount: String!
    var currentPath: [String] = []
    var destinationMount: String!
    var destinationPath: [String] = []
    var arePathsTheSame: Bool {
        return currentMount == destinationMount && currentPath.last! == destinationPath.last!
    }

    // MARK: - Initializers
    private init() {}

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

    // MARK: - Shared instance
    static let shared: DigiClient = DigiClient()

    func equalizePaths() {
        destinationMount = currentMount
        destinationPath = currentPath
    }

    func networkTask(requestType: String, method: String, headers: [String: String]?,
                     json: [String: String]?, parameters: [String: Any]?,
                     completionHandler: @escaping (_ data: Any?, _ response: Int?, _ error: Error?) -> Void) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        /* 1. Build the URL, Configure the request */
        let url = self.getURL(method: method, parameters: parameters)

        var request = self.getURLRequest(url: url, requestType: requestType, headers: headers)

        // add json object to request
        if let json = json {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: json, options: [])
            } catch {
                completionHandler(nil, nil, JSONError.parce("Could not convert json into data!"))
            }
        }

        /* 2. Make the request */
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            // stop network indication
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }

            /* GUARD: Was there an error? */
            guard error == nil else {
                completionHandler(nil, nil, NetworkingError.get("There was an error with your request: \(error?.localizedDescription)"))
                return
            }

            /* GUARD: Did we get a statusCode? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                completionHandler(nil, nil, NetworkingError.get("There was an error with your request: \(error?.localizedDescription)"))
                return
            }

            // Did we get a succesfull status code?
            if statusCode < 200 || statusCode > 299 {
                completionHandler(nil, statusCode, nil)
                return
            }

            /* GUARD: Was there any data returned? */
            guard let data = data else {
                completionHandler(nil, statusCode, NetworkingError.data("No data was returned by the request!"))
                return
            }

            guard data.count > 0 else {
                completionHandler(data, statusCode, nil)
                return
            }

            /* 3. Parse the data and use the data (happens in completion handler) */
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                completionHandler(json, statusCode, nil)
            } catch {
                completionHandler(nil, statusCode, JSONError.parce("Could not parse the data as JSON"))
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
            components.percentEncodedQuery = components.percentEncodedQuery?
                .replacingOccurrences(of: "+", with: "%2B")
                .replacingOccurrences(of: ";", with: "%3B")
        }
        return components.url!
    }

    private func getURLRequest(url: URL, requestType: String, headers: [String: String]?) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = requestType
        request.allHTTPHeaderFields = headers
        return request
    }
}

