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
            (json, statusCode, error) in
            if let error = error {
                completionHandlerforAuth(false, error)
                return
            }
            if statusCode == 200 {
                if let json = json as? [String: String] {
                    self.token = json["token"]
                    completionHandlerforAuth(true, nil)
                }
            } else {
                completionHandlerforAuth(false, nil)
            }
        }
    }

    func getLocations(completionHandler: @escaping (_ result: [Mount]?, _ error: Error?) -> Void)
    {
        let method = Methods.Mounts
        var headers = DefaultHeaders.Headers
        headers["Authorization"] = "Token \(DigiClient.shared.token!)"

        networkTask(requestType: "GET", method: method, headers: headers, json: nil, parameters: nil) {
            (data, responseCode, error) in
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
        headers["Authorization"] = "Token \(DigiClient.shared.token!)"
        let parameters = [ParametersKeys.Path: queryPath]

        networkTask(requestType: "GET", method: method, headers: headers, json: nil, parameters: parameters) {
            (data, responseCode, error) in
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
        let method =  Methods.GetFile.replacingOccurrences(of: "{id}", with: DigiClient.shared.currentMount)

        // prepare the query paramenter path with the current File path
        let parameters = [ParametersKeys.Path: DigiClient.shared.currentPath.last!]

        // create url from method and paramenters
        let url = DigiClient.shared.getURL(method: method, parameters: parameters)

        // create url request with the current token in the HTTP headers
        var request = URLRequest(url: url)
        request.addValue("Token " + DigiClient.shared.token, forHTTPHeaderField: "Authorization")

        // create and start download task
        let downloadTask = session.downloadTask(with: request)
        downloadTask.resume()

        return session
    }

    func rename(path: String, newName: String, completionHandler: @escaping (_ statusCode: Int?, _ error: Error?) -> Void) {
        // prepare the method string for rename the element by inserting the current mount
        let method = Methods.Rename.replacingOccurrences(of: "{id}", with: DigiClient.shared.currentMount)

        // prepare headers
        var headers = DefaultHeaders.Headers
        headers["Authorization"] = "Token \(DigiClient.shared.token!)"

        // prepare parameters (element path to be renamed
        let parameters = [ParametersKeys.Path: path]

        // prepare new name in request body
        let jsonBody = ["name": newName]

        networkTask(requestType: "PUT", method: method, headers: headers, json: jsonBody, parameters: parameters) { (_, statusCode, error) in
            completionHandler(statusCode, error)
        }
    }

    func delete(path: String, name: String, completionHandler: @escaping (_ statusCode: Int?, _ error: Error?) -> Void) {
        // prepare the method string for rename the element by inserting the current mount
        let method = Methods.Remove.replacingOccurrences(of: "{id}", with: DigiClient.shared.currentMount)

        // prepare headers
        var headers: [String: String] = [ : ]
        headers["Authorization"] = "Token \(DigiClient.shared.token!)"

        // prepare parameters (element path to be renamed
        let parameters = [ParametersKeys.Path: path]

        networkTask(requestType: "DELETE", method: method, headers: headers, json: nil, parameters: parameters) { (_, statusCode, error) in
            completionHandler(statusCode, error)
        }
    }

    func createFolder(path: String , name: String, completionHandler: @escaping (_ statusCode: Int?, _ error: Error?) -> Void) {
        // prepare the method string for create new folder
        let method = Methods.CreateFolder.replacingOccurrences(of: "{id}", with: DigiClient.shared.currentMount)

        // prepare headers
        var headers = DefaultHeaders.Headers
        headers["Authorization"] = "Token \(DigiClient.shared.token!)"

        // prepare parameters (element path to be renamed
        let parameters = [ParametersKeys.Path: path]

        // prepare new folder name in request body
        let jsonBody = ["name": name]

        networkTask(requestType: "POST", method: method, headers: headers, json: jsonBody, parameters: parameters) { (_, statusCode, error) in
            completionHandler(statusCode, error)
        }
    }

    func getFolderSize(path: String, completionHandler: @escaping (_ size: Int64?, _ error: Error?) -> Void) {
        // prepare the method string for create new folder
        let method = Methods.Tree.replacingOccurrences(of: "{id}", with: DigiClient.shared.currentMount)

        // prepare headers
        var headers: [String: String] = ["Accept": "application/json"]
        headers["Authorization"] = "Token \(DigiClient.shared.token!)"

        // prepare parameters (element path to be renamed
        let path = DigiClient.shared.currentPath.last! + path
        let parameters = [ParametersKeys.Path: path]

        func getChildSize(_ parent: [String: Any]) -> Int64 {
            var size: Int64 = 0
            if let childType = parent["type"] as? String, childType == "file" {
                if let childSize = parent["size"] as? Int64 {
                    return childSize
                }
            }
            if let children = parent["children"] as? [[String: Any]], !children.isEmpty {
                for child in children {
                    size += getChildSize(child)
                }
            }
            return size
        }

        networkTask(requestType: "GET", method: method, headers: headers, json: nil, parameters: parameters) { (json, statusCode, error) in
            if let error = error {
                completionHandler(nil, error)
                return
            }
            var size: Int64 = 0
            guard let json = json as? [String: Any] else {
                completionHandler(nil, nil)
                return
            }
            if let children = json["children"] as? [[String: Any]] {
                for child in children {
                    size += getChildSize(child)
                }
            }
            completionHandler(size, nil)
        }
    }
}
