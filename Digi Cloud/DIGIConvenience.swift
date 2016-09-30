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
                    let mounts = mountsList.flatMap { Mount(JSON: $0) }
                    completionHandler(mounts, nil)

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
                    let content = fileList.flatMap { File(JSON: $0) }
                    completionHandler(content, nil)
                    
                } else {
                    completionHandler(nil, JSONError.parce("Could not parce data (getFiles)"))
                }
            }
        }
    }
    
    func startFileDownload(delegate: AnyObject) -> URLSession {
        
        // create the special session with custom delegate for download task
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: delegate as? ContentViewController, delegateQueue: nil)
        
        // prepare the method string for download file by inserting the current mount
        let method =  Methods.GetFile.replacingOccurrences(of: "{id}", with: DigiClient.shared().currentMount)
        
        // prepare the query paramenter path with the current File path
        let parameters = [ParametersKeys.Path: DigiClient.shared().currentPath.last!]
        
        // create url from method and paramenters
        let url = DigiClient.shared().getURL(method: method, parameters: parameters)
        
        // create url request with the current token in the HTTP headers
        var request = URLRequest(url: url)
        request.addValue("Token " + DigiClient.shared().token, forHTTPHeaderField: "Authorization")
        
        // create and start download task
        let downloadTask = session.downloadTask(with: request)
        downloadTask.resume()
        
        return session
    }
    
}
