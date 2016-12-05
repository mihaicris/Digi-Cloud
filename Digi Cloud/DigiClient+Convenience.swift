//
//  DigiClient+Convenience.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 26/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import Foundation

extension DigiClient {

    func authenticate(email: String, password: String, completionHandlerforAuth: @escaping(_ success: Bool, _ error: Error?) -> Void) {
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

    func getUserInfo(completion: @escaping(_ json: Any? , _ statusCode: Int?, _ error: Error?) -> Void) {
        let method = Methods.User

        let headers: [String: String] = ["Accept": "application/json",
                                         "Authorization": "Token \(DigiClient.shared.token!)"]

        networkTask(requestType: "GET", method: method, headers: headers, json: nil, parameters: nil) {
            (data, statusCode, error) in

            guard error == nil else {
                completion(nil, nil, error)
                return
            }

            guard statusCode == 200 else {
                completion(nil, statusCode, nil)
                return
            }
            completion(data, statusCode, nil)
        }
    }

    func getLocations(completionHandler: @escaping(_ result: [Location]?, _ error: Error?) -> Void) {
        let method = Methods.Mounts
        var headers = DefaultHeaders.Headers
        headers["Authorization"] = "Token \(DigiClient.shared.token!)"

        networkTask(requestType: "GET", method: method, headers: headers, json: nil, parameters: nil) {
            (data, statusCode, error) in
            if let error = error {
                completionHandler(nil, error)
            } else {
                if let dict = data as? [String: Any] {
                    guard let mountsList = dict["mounts"] as? [Any] else {
                        completionHandler(nil, JSONError.parce("Could not parce mountlist"))
                        return
                    }
                    var locations: [Location] = []
                    for mountJSON in mountsList {
                        if let mount = Mount(JSON: mountJSON) {
                            locations.append(Location(mount: mount, path: "/"))
                        }
                    }
                    completionHandler(locations, nil)

                } else {
                    completionHandler(nil, JSONError.parce("Could not parce data (getLocations)"))
                }
            }
        }
    }

    func getLocationContent(location: Location, completionHandler: @escaping(_ result: [Node]?, _ error: Error?) -> Void) {
        let method = Methods.ListFiles.replacingOccurrences(of: "{id}", with: location.mount.id)
        var headers = DefaultHeaders.Headers
        headers["Authorization"] = "Token \(DigiClient.shared.token!)"
        let parameters = [ParametersKeys.Path: location.path]

        networkTask(requestType: "GET", method: method, headers: headers, json: nil, parameters: parameters) {
            (data, responseCode, error) in
            if let error = error {
                completionHandler(nil, error)
                return
            } else {
                if let dict = data as? [String: Any] {
                    guard let fileList = dict["files"] as? [[String: Any]] else {
                        completionHandler(nil, JSONError.parce("Could not parce filelist"))
                        return
                    }
                    let content = fileList.flatMap { Node(JSON: $0) }
                    completionHandler(content, nil)
                } else {
                    completionHandler(nil, JSONError.parce("Could not parce data (getFiles)"))
                }
            }
        }
    }

    func startFileDownload(location: Location, delegate: AnyObject) -> URLSession {

        // create the special session with custom delegate for download task
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: delegate as? ContentViewController, delegateQueue: nil)

        // prepare the method string for download file by inserting the current mount
        let method =  Methods.GetFile.replacingOccurrences(of: "{id}", with: location.mount.id)

        // prepare the query paramenter path with the current File path
        let parameters = [ParametersKeys.Path: location.path]

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

    func renameNode(location: Location, newName: String, completionHandler: @escaping(_ statusCode: Int?, _ error: Error?) -> Void) {
        // prepare the method string for rename the node by inserting the current mount
        let method = Methods.Rename.replacingOccurrences(of: "{id}", with: location.mount.id)

        // prepare headers
        var headers = DefaultHeaders.Headers
        headers["Authorization"] = "Token \(DigiClient.shared.token!)"

        // prepare parameters (path of the node to be renamed
        let parameters = [ParametersKeys.Path: location.path]

        // prepare new name in request body
        let jsonBody = ["name": newName]

        networkTask(requestType: "PUT", method: method, headers: headers, json: jsonBody, parameters: parameters) { (_, statusCode, error) in
            completionHandler(statusCode, error)
        }
    }

    func deleteNode(location: Location, completionHandler: @escaping(_ statusCode: Int?, _ error: Error?) -> Void) {
        // prepare the method string for rename the node by inserting the current mount
        let method = Methods.Remove.replacingOccurrences(of: "{id}", with: location.mount.id)

        // prepare headers
        var headers: [String: String] = [:]
        headers["Authorization"] = "Token \(DigiClient.shared.token!)"

        // prepare parameters (node path to be renamed
        let parameters = [ParametersKeys.Path: location.path]

        networkTask(requestType: "DELETE", method: method, headers: headers, json: nil, parameters: parameters) { (_, statusCode, error) in
            completionHandler(statusCode, error)
        }
    }

    func createFolder(location: Location, name: String, completionHandler: @escaping(_ statusCode: Int?, _ error: Error?) -> Void) {
        // prepare the method string for create new folder
        let method = Methods.CreateFolder.replacingOccurrences(of: "{id}", with: location.mount.id)

        // prepare headers
        var headers = DefaultHeaders.Headers
        headers["Authorization"] = "Token \(DigiClient.shared.token!)"

        // prepare parameters
        let parameters = [ParametersKeys.Path: location.path]

        // prepare new folder name in request body
        let jsonBody = ["name": name]

        networkTask(requestType: "POST", method: method, headers: headers, json: jsonBody, parameters: parameters) { (_, statusCode, error) in
            completionHandler(statusCode, error)
        }
    }

    func getTree(for location: Location, completionHandler: @escaping (_ json: [String: Any]?, _ error: Error?) -> Void ) {
        let method = Methods.Tree.replacingOccurrences(of: "{id}", with: location.mount.id)

        var headers: [String: String] = ["Accept": "application/json"]
        headers["Authorization"] = "Token \(DigiClient.shared.token!)"

        let parameters = [ParametersKeys.Path: location.path]

        networkTask(requestType: "GET", method: method, headers: headers, json: nil, parameters: parameters) { (json, statusCode, error) in
            if let error = error {
                completionHandler(nil, error)
                return
            }
            guard let json = json as? [String: Any] else {
                completionHandler(nil, nil)
                return
            }
            completionHandler(json, nil)
        }
    }

    /// Get information about a folder
    ///
    /// - Parameters:
    ///   - path: path of the folder
    ///   - completionHandler: completion handler with info about folder and error

    func getFolderInfo(location: Location, completionHandler: @escaping(_ size: (Int64?, Int?, Int?), _ error: Error?) -> Void) {
        // prepare the method string for create new folder
        let method = Methods.Tree.replacingOccurrences(of: "{id}", with: location.mount.id)

        // prepare headers
        var headers: [String: String] = ["Accept": "application/json"]
        headers["Authorization"] = "Token \(DigiClient.shared.token!)"

        // prepare parameters (node path to be renamed
        let parameters = [ParametersKeys.Path: location.path]

        /// Get information from Dictionary content (JSON folder tree)
        ///
        /// - Parameter parent: parent folder
        /// - Returns: return tuple with (size of child, number of files, number of folders)
        func getChildInfo(_ parent: [String: Any]) -> (Int64, Int, Int) {
            var size: Int64 = 0
            var files: Int = 0
            var folders: Int = 0
            if let childType = parent["type"] as? String, childType == "file" {
                files += 1
                if let childSize = parent["size"] as? Int64 {
                    return (childSize, files, folders)
                }
            }
            if let children = parent["children"] as? [[String: Any]] {
                folders += 1
                for child in children {
                    let info = getChildInfo(child)
                    size += info.0
                    files += info.1
                    folders += info.2
                }
            }
            return (size, files, folders)
        }

        getTree(for: location) { json, error in
            if let error = error {
                completionHandler((nil, nil, nil), error)
                return
            }
            guard let json = json else {
                completionHandler((nil, nil, nil), nil)
                return
            }
            let info = getChildInfo(json)

            // Subtracting 1 because the root folder is also counted
            completionHandler((info.0, info.1, info.2 - 1), nil)
        }
    }

    /// Send a request to DIGI API to copy or move a node
    ///
    /// - Parameters:
    ///   - action:            Action Type, expected ActionType.move or ActionType.copy
    ///   - from:              Source location
    ///   - to:                Destination location
    ///   - completion:        Function to handle the status code and error response
    ///   - statusCode:        Returned HTTP request Status Code
    ///   - error:             Networking error (nil if no error)

    func copyOrMoveNode(action:     ActionType, from: Location, to: Location,
                        completion: @escaping (_ statusCode: Int?, _ error: Error?) -> Void) {

        var method : String

        switch action {
        case .copy:
            method = Methods.Copy.replacingOccurrences(of: "{id}", with: from.mount.id)
        case .move:
            method = Methods.Move.replacingOccurrences(of: "{id}", with: from.mount.id)
        default:
            return
        }

        var headers = DefaultHeaders.Headers
        headers["Authorization"] = "Token \(DigiClient.shared.token!)"

        let parameters = [ParametersKeys.Path: from.path]

        let json: [String: String] = ["toMountId": to.mount.id, "toPath": to.path]
        
        networkTask(requestType: "PUT", method: method, headers: headers, json: json, parameters: parameters) { (dataResponse, statusCode, error) in
            completion(statusCode, error)
        }
    }
}
