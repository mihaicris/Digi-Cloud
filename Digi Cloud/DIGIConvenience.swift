//
//  DIGIConvenience.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 26/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import Foundation

extension DigiClient {
    
    func authenticate(email: String, password: String, completionHandlerforAuth: @escaping (_ success: Bool, _ error: Error?) -> Void) -> URLSessionDataTask
    {
        let method = Methods.Token
        let headers = DefaultHeaders.Headers
        let jsonBody = ["password": password, "email": email]
        
        let task = networkTask(requestType: "POST", method: method, headers: headers, json: jsonBody, parameters: nil) {
            (data, error) in
            if let error = error {
                completionHandlerforAuth(false, error)
            } else {
                if let data = data as? [String: String] {
                    self.token = data["token"]
                }
                completionHandlerforAuth(true, nil)
            }
        }
        return task
    }
    
    
    func getLocations(completionHandler: @escaping (_ result: [Mount]?, _ error: Error?) -> Void) -> URLSessionDataTask
    {
        let method = Methods.Mounts
        var headers = DefaultHeaders.Headers
        headers["Authorization"] = "Token \(DigiClient.shared().token!)"
        
        let task = networkTask(requestType: "GET", method: method, headers: headers, json: nil, parameters: nil) {
            (data, error) in
            if let error = error {
                completionHandler(nil, error)
            } else {
                if let dict = data as? [String: Any] {
                    
                    guard let mountsList = dict["mounts"] as? [Any] else {
                        completionHandler(nil, JSONError.parce("Could not parce mountlist"))
                        return
                    }

                    var mounts: [Mount] = []
                    
                    for item in mountsList  {
                        if let mountObject = Mount(JSON: item) {
                            mounts.append(mountObject)
                        }
                    completionHandler(mounts, nil)
                    
                    }
                } else {
                    completionHandler(nil, JSONError.parce("Could not parce data (getLocations)"))
                }
            }
        }
        return task
    }
}
