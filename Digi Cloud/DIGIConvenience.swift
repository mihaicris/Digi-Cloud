//
//  DIGIConvenience.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 26/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import Foundation

extension DigiClient {
    
    func authenticate(email: String, password: String, completionHandlerforAuth: @escaping (_ success: Bool, _ error: Error?) -> Void)
    {
        let method = Methods.Token
        let headers = DefaultHeaders.Headers
        let jsonBody = ["password": password, "email": email]
        
        networkTask(requestType: "POST", method: method, headers: headers, json: jsonBody, parameters: nil) {
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
    }
    
    func getLocations(completionHandler: @escaping (_ result: [Mount]?, _ error: Error?) -> Void)
    {
        let method = Methods.Mounts
        var headers = DefaultHeaders.Headers
        headers["Authorization"] = "Token \(DigiClient.shared().token!)"
        
        networkTask(requestType: "GET", method: method, headers: headers, json: nil, parameters: nil) {
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
    }
    
    
    func getLocationContent(mount: String, queryPath: String, completionHandler: @escaping (_ result: [File]?, _ error: Error?) -> Void)
    {
        let method = Methods.ListFiles.replacingOccurrences(of: "{id}", with: mount)
        var headers = DefaultHeaders.Headers
        headers["Authorization"] = "Token \(DigiClient.shared().token!)"
        let parameters = [ParametersKeys.Path: queryPath]
        
        networkTask(requestType: "GET", method: method, headers: headers, json: nil, parameters: parameters) {
            (data, error) in
            if let error = error {
                completionHandler(nil, error)
            } else {
                if let dict = data as? [String: Any] {
                    guard let fileList = dict["files"] as? [[String: Any]] else {
                        completionHandler(nil, JSONError.parce("Could not parce filelist"))
                        return
                    }
                    var content: [File] = []
                    
                    for item in fileList  {
                        if let file = File(JSON: item) {
                            content.append(file)
                        }
                    }                    
                    completionHandler(content, nil)
                    
                } else {
                    completionHandler(nil, JSONError.parce("Could not parce data (getFiles)"))
                }
            } // end if
        } // end networkTasl
    } // end getLocationContent
}
