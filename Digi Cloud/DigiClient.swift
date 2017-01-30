//
//  DigiClient.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 26/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

// Singleton class for DIGI Client

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
    case revoke(String)
}

struct FolderInfo {
    var size: Int64 = 0
    var files: Int = 0
    var folders: Int = 0
}

final class DigiClient {

    // MARK: - Properties

    static let shared: DigiClient = DigiClient()

    var session: URLSession?

    var task: URLSessionDataTask?

    var token: String!

    // MARK: - Initializers and Deinitializers

    private init() {
        renewSession()
    }

    // MARK: - Helper Functions

    func renewSession() {
        session?.invalidateAndCancel()
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 20
        config.allowsCellularAccess = AppSettings.allowsCellularAccess
        session = URLSession(configuration: config)
    }

    /// Send a HTTP Network Request
    ///
    /// - Parameters:
    ///   - requestType: The request type like GET, POST, PUT, DELETE, etc.
    ///   - method: The method of the HTTP request (without http://)
    ///   - headers: Dictionary with HTTP headers
    ///   - json: Dictionary for HTTP Body JSON
    ///   - parameters: A dictionary with query parameters in the request
    ///   - completion: The block called after the server has responded
    ///   - data: The data of the network response
    ///   - response: The status code of the network response
    ///   - error: The error occurred in the network request, nil for no error.
    func networkTask(requestType: String, method: String, headers: [String: String]?, json: [String: String]?,
                     parameters: [String: Any]?,
                     completion: @escaping(_ data: Any?, _ response: Int?, _ error: Error?) -> Void) {

        #if DEBUG
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        #endif

        /* 1. Build the URL, Configure the request */
        let url = self.getURL(method: method, parameters: parameters)

        var request = self.getURLRequest(url: url, requestType: requestType, headers: headers)

        // add json object to request
        if let json = json {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: json, options: [])
            } catch {
                completion(nil, nil, JSONError.parce("Could not convert json into data!"))
            }
        }

        /* 2. Make the request */
        task = session?.dataTask(with: request) { (data, response, error) in

            DispatchQueue.main.async {

                #if DEBUG
                    // stop network indication
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                #endif

                /* GUARD: Was there an error? */
                guard error == nil else {
                    completion(nil, nil, NetworkingError.get("There was an error with your request: \(error!.localizedDescription)"))
                    return
                }

                /* GUARD: Did we get a statusCode? */
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                    completion(nil, nil, NetworkingError.get("There was an error with your request: \(error!.localizedDescription)"))
                    return
                }

                // Did we get a successful status code?
                if statusCode < 200 || statusCode > 299 {
                    completion(nil, statusCode, nil)
                    return
                }

                /* GUARD: Was there any data returned? */
                guard let data = data else {
                    completion(nil, statusCode, NetworkingError.data("No data was returned by the request!"))
                    return
                }

                guard data.count > 0 else {
                    completion(data, statusCode, nil)
                    return
                }

                /* 3. Parse the data and use the data (happens in completion handler) */
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    completion(json, statusCode, nil)
                } catch {
                    completion(nil, statusCode, JSONError.parce("Could not parse the data as JSON"))
                }
            } // End of dispatched block
        }
        /* 4. Start the request */
        task?.resume()
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

    func authenticate(username: String, password: String,
                      completion: @escaping(_ token: String?, _ error: Error?) -> Void) {
        let method = Methods.Token
        let headers = DefaultHeaders.Headers
        let jsonBody = ["password": password, "email": username]

        networkTask(requestType: "POST", method: method, headers: headers, json: jsonBody, parameters: nil) { json, statusCode, error in
            guard error == nil else {
                print(error!.localizedDescription)
                completion(nil, error!)
                return
            }
            if statusCode == 200 {
                if let json = json as? [String: String] {
                    let token  = json["token"]
                    completion(token, nil)
                }
            } else {
                completion(nil, nil)
            }
        }
    }

    func revokeAuthentication(for token: String, completion: @escaping(_ statusCode: Int?, _ error: Error?) -> Void) {
        let method = Methods.Token
        let headers: [String: String] = ["Authorization": "Token \(token)"]

        networkTask(requestType: "DELETE", method: method, headers: headers, json: nil, parameters: nil) { _, statusCode, error in
            guard error == nil else {
                completion(nil, Authentication.revoke("There was an error at revoke token API request."))
                return
            }
            completion(statusCode, nil)
        }
    }

    func getUserInfo(for token: String, completion: @escaping(_ response: (firstName: String, lastName: String)?, _ error: Error?) -> Void) {

        let method = Methods.User

        let headers: [String: String] = [HeadersKeys.Accept: "application/json",
                                         "Authorization": "Token \(token)"]

        networkTask(requestType: "GET", method: method, headers: headers, json: nil, parameters: nil) { jsonData, statusCode, error in

            guard error == nil else {
                completion(nil, error)
                return
            }

            guard statusCode == 200 else {
                completion(nil, NetworkingError.wrongStatus("Wrong status \(statusCode) while receiving user info request."))
                return
            }

            guard let json = jsonData as? [String: String],
                let firstName = json["firstName"],
                let lastName = json["lastName"] else {
                    completion(nil, JSONError.parce("Could not parce json response for user info request."))
                    return
            }

            completion((firstName, lastName), nil)
        }
    }

    func getDIGIStorageLocations(completion: @escaping(_ result: [Location]?, _ error: Error?) -> Void) {
        let method = Methods.Mounts
        var headers = DefaultHeaders.Headers
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token!)"

        networkTask(requestType: "GET", method: method, headers: headers, json: nil, parameters: nil) { data, _, error in
            if let error = error {
                completion(nil, error)
            } else {
                if let dict = data as? [String: Any] {
                    guard let mountsList = dict["mounts"] as? [Any] else {
                        completion(nil, JSONError.parce("Could not parce mount "))
                        return
                    }
                    var locations: [Location] = []
                    for mountJSON in mountsList {
                        if let mount = Mount(JSON: mountJSON) {
                            locations.append(Location(mount: mount, path: "/"))
                        }
                    }
                    completion(locations, nil)

                } else {
                    completion(nil, JSONError.parce("Could not parce data (getLocations)"))
                }
            }
        }
    }

    /// Gets the content of nodes of a location in the Cloud storage
    ///
    /// - Parameters:
    ///   - location: The location to get the content
    ///   - completion: The block called after the server has responded
    ///   - result: Returned content as an array of nodes
    ///   - error: The error occurred in the network request, nil for no error.
    func getContent(of location: Location,
                    completion: @escaping(_ result: [Node]?, _ error: Error?) -> Void) {
        
        let method = Methods.ListFiles.replacingOccurrences(of: "{id}", with: location.mount.id)
        var headers = DefaultHeaders.Headers
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token!)"
        let parameters = [ParametersKeys.Path: location.path]

        networkTask(requestType: "GET", method: method, headers: headers, json: nil, parameters: parameters) { data, statusCode, error in
            guard error == nil else {
                completion(nil, error!)
                return
            }
            guard statusCode != 400 else {
                let message = NSLocalizedString("Location is no longer available!", comment: "Error message")
                completion(nil, NetworkingError.wrongStatus(message))
                return
            }
            if let dict = data as? [String: Any] {
                guard let nodeList = dict["files"] as? [[String: Any]] else {
                    completion(nil, JSONError.parce("Could not parce filelist"))
                    return
                }
                var content: [Node] = []
                for nodeJSON in nodeList {
                    guard let nodeName = nodeJSON["name"] as? String else {
                        completion (nil, JSONError.parce("JSON Error"))
                        return
                    }
                    let locationNode = Location(mount: location.mount, path: location.path + nodeName)
                    guard let node = Node(JSON: nodeJSON, location: locationNode) else {
                        completion (nil, JSONError.parce("JSON Error"))
                        return
                    }
                    content.append(node)
                }
                completion(content, nil)
            } else {
                completion(nil, JSONError.parce("Could not parce data (getFiles)"))
            }

        }
    }

    /// Starts the download of a file
    ///
    /// - Parameters:
    ///   - location: Location of the file
    ///   - delegate: The object delegate which will handle the events while and after downloading
    /// - Returns: The URL session for the download
    func startDownloadFile(at location: Location, delegate: AnyObject) -> URLSession {

        // create the special session with custom delegate for download task
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: delegate as? ContentViewController, delegateQueue: nil)

        // prepare the method string for download file by inserting the current mount
        let method =  Methods.GetFile.replacingOccurrences(of: "{id}", with: location.mount.id)

        // prepare the query parameter path with the current File path
        let parameters = [ParametersKeys.Path: location.path]

        // create url from method and parameters
        let url = DigiClient.shared.getURL(method: method, parameters: parameters)

        // create url request with the current token in the HTTP headers
        var request = URLRequest(url: url)
        request.addValue("Token " + DigiClient.shared.token, forHTTPHeaderField: "Authorization")

        // create and start download task
        let downloadTask = session.downloadTask(with: request)
        downloadTask.resume()

        return session
    }

    /// Renames a node
    ///
    /// - Parameters:
    ///   - location: Location of the node to be renamed
    ///   - name: The new name of the node
    ///   - completion: The block called after the server has responded
    ///   - statusCode: Returned network request status code
    ///   - error: The error occurred in the network request, nil for no error.
    func renameNode(at location: Location,
                    with name: String,
                    completion: @escaping(_ statusCode: Int?, _ error: Error?) -> Void) {
        // prepare the method string for rename the node by inserting the current mount
        let method = Methods.Rename.replacingOccurrences(of: "{id}", with: location.mount.id)

        // prepare headers
        var headers = DefaultHeaders.Headers
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token!)"

        // prepare parameters (path of the node to be renamed
        let parameters = [ParametersKeys.Path: location.path]

        // prepare new name in request body
        let jsonBody = ["name": name]

        networkTask(requestType: "PUT", method: method, headers: headers, json: jsonBody, parameters: parameters) { (_, statusCode, error) in
            completion(statusCode, error)
        }
    }

    /// Deletes a node (file or folder)
    ///
    /// - Parameters:
    ///   - location: Location of the node
    ///   - completion: The block called after the server has responded
    ///   - statusCode: Returned network request status code
    ///   - error: The error occurred in the network request, nil for no error.
    func deleteNode(at location: Location,
                    completion: @escaping(_ statusCode: Int?, _ error: Error?) -> Void) {
        // prepare the method string for rename the node by inserting the current mount
        let method = Methods.Remove.replacingOccurrences(of: "{id}", with: location.mount.id)

        // prepare headers
        var headers: [String: String] = [:]
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token!)"

        // prepare parameters (node path to be renamed
        let parameters = [ParametersKeys.Path: location.path]

        networkTask(requestType: "DELETE", method: method, headers: headers, json: nil, parameters: parameters) { (_, statusCode, error) in
            completion(statusCode, error)
        }
    }

    /// Create a node of type folder
    ///
    /// - Parameters:
    ///   - location: Location at which the folder is created
    ///   - name: Folder name
    ///   - completion: The block called after the server has responded
    ///   - statusCode: Returned network request status code
    ///   - error: The error occurred in the network request, nil for no error.
    func createFolderNode(at location: Location,
                          with name: String,
                          completion: @escaping(_ statusCode: Int?, _ error: Error?) -> Void) {
        // prepare the method string for create new folder
        let method = Methods.CreateFolder.replacingOccurrences(of: "{id}", with: location.mount.id)

        // prepare headers
        var headers = DefaultHeaders.Headers
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token!)"

        // prepare parameters
        let parameters = [ParametersKeys.Path: location.path]

        // prepare new folder name in request body
        let jsonBody = [DataJSONKeys.folderName: name]

        networkTask(requestType: "POST", method: method, headers: headers, json: jsonBody, parameters: parameters) { (_, statusCode, error) in
            completion(statusCode, error)
        }
    }

    /// Search for files or folders
    ///
    /// - Parameters:
    ///   - query: String to search
    ///   - location: Location to search (mount and path). If nil, search is made in all locations
    ///   - completion: The block called after the server has responded
    ///   - json: An array containing the search hits (Nodes).
    ///   - error: The error occurred in the network request, nil for no error.
    func searchNodes(query: String,
                     at location: Location?,
                     completion: @escaping (_ json: [Node]?, _ error: Error?) -> Void) {
        let method = Methods.Search

        var headers: [String: String] = [HeadersKeys.Accept: "application/json"]
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token!)"

        var parameters: [String: String] = [
            ParametersKeys.QueryString: query
        ]
        if let location = location {
            parameters[ParametersKeys.MountID] = location.mount.id
            parameters[ParametersKeys.Path] = location.path
        }

        networkTask(requestType: "GET",
                    method: method,
                    headers: headers,
                    json: nil,
                    parameters: parameters) { json, _, error in
                        if let error = error {
                            completion(nil, error)
                            return
                        }
                        guard let json = json as? [String: Any],
                            let hitsJSON = json["hits"] as? [[String: Any]],
                            let mountsJSON = json["mounts"] as? [String: Any]
                            else {
                                completion(nil, JSONError.parce("Couldn't parce the json to get the hits and mounts from search results."))
                                return
                        }

                        var results: [Node] = []

                        for hitJSON in hitsJSON {
                            guard let hitMountId = hitJSON["mountId"] as? String,
                                let hitMount = mountsJSON[hitMountId] as? [String: Any],
                                let hitMountStruct = Mount(JSON: hitMount),
                                let hitPath = hitJSON["path"] as? String,
                                let hitName = hitJSON["name"] as? String,
                                let hitType = hitJSON["type"] as? String,
                                let hitModified = hitJSON["modified"] as? TimeInterval,
                                let hitSize = hitJSON["size"] as? Int64,
                                let hitScore = hitJSON["score"] as? Double,
                                let hitContentType = hitJSON["contentType"] as? String else {
                                    completion(nil, JSONError.parce("Couldn't parce the json to get the hits and mounts from search results."))
                                    return
                            }
                            let hitLocation = Location(mount: hitMountStruct, path: hitPath)
                            let hitNode = Node(name: hitName, type: hitType, modified: hitModified, size: hitSize, contentType: hitContentType,
                                               hash: "", score: hitScore, location: hitLocation)
                            results.append(hitNode)
                        }

                        completion(results, nil)
        }
    }

    /// Get the complete tree structure of a location
    /// - Parameters:
    ///   - location: The location of which the tree is returned
    ///   - completion: The block called after the server has responded
    ///   - json: The dictionary [String: Any] containing the search hits.
    ///   - error: The error occurred in the network request, nil for no error.
    func getTree(at location: Location,
                 completion: @escaping (_ json: [String: Any]?, _ error: Error?) -> Void ) {
        let method = Methods.Tree.replacingOccurrences(of: "{id}", with: location.mount.id)

        var headers: [String: String] = [HeadersKeys.Accept: "application/json"]
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token!)"

        let parameters = [ParametersKeys.Path: location.path]

        networkTask(requestType: "GET", method: method, headers: headers, json: nil, parameters: parameters) { (json, _, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let json = json as? [String: Any] else {
                completion(nil, nil)
                return
            }
            completion(json, nil)
        }
    }

    /// Get information about a folder
    ///
    /// - Parameters:
    ///   - location: The location of which we get the information
    ///   - completion: The block called after the server has responded
    ///   - info: Tuple containing size, number of files and number of folders
    ///   - error: The error occurred in the network request, nil for no error.
    func getFolderInfo(at location: Location,
                       completion: @escaping(_ info: FolderInfo?, _ error: Error?) -> Void) {
        // prepare the method string for create new folder
        let method = Methods.Tree.replacingOccurrences(of: "{id}", with: location.mount.id)

        // prepare headers
        var headers: [String: String] = [HeadersKeys.Accept: "application/json"]
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token!)"

        // prepare parameters (node path to be renamed
        let parameters = [ParametersKeys.Path: location.path]

        /// Get information from Dictionary content (JSON folder tree)
        ///
        /// - Parameter parent: parent folder
        /// - Returns: return tuple with (size of child, number of files, number of folders)
        func getChildInfo(_ parent: [String: Any]) -> FolderInfo {
            var info = FolderInfo()
            if let childType = parent["type"] as? String, childType == "file" {
                info.files += 1
                if let size = parent["size"] as? Int64 {
                    info.size += size
                    return info
                }
            }
            if let children = parent["children"] as? [[String: Any]] {
                info.folders += 1
                for child in children {
                    let childInfo = getChildInfo(child)
                    info.size += childInfo.size
                    info.files += childInfo.files
                    info.folders += childInfo.folders
                }
            }
            return info
        }

        getTree(at: location) { json, error in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let json = json else {
                completion(nil, nil)
                return
            }
            var info = getChildInfo(json)
            info.folders -= 1

            // Subtracting 1 because the root folder is also counted
            completion(info, nil)
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
    func copyOrMoveNode(action: ActionType,
                        from: Location,
                        to: Location,
                        completion: @escaping (_ statusCode: Int?, _ error: Error?) -> Void) {

        var method: String

        switch action {
        case .copy:
            method = Methods.Copy.replacingOccurrences(of: "{id}", with: from.mount.id)
        case .move:
            method = Methods.Move.replacingOccurrences(of: "{id}", with: from.mount.id)
        default:
            return
        }

        var headers = DefaultHeaders.Headers
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token!)"

        let parameters = [ParametersKeys.Path: from.path]

        let json: [String: String] = ["toMountId": to.mount.id, "toPath": to.path]

        networkTask(requestType: "PUT", method: method, headers: headers, json: json, parameters: parameters) { (_, statusCode, error) in
            completion(statusCode, error)
        }
    }

}
