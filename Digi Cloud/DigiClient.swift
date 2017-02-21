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
    case parse(String)
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
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 30
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
    func networkTask(requestType: String, method: String, headers: [String: String]?, json: [String: Any]?, parameters: [String: Any]?,
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
                completion(nil, nil, JSONError.parse("Could not convert json into data!"))
            }
        }

        /* 2. Make the request */
        task = session?.dataTask(with: request) { (data, response, error) in

            DispatchQueue.main.async {

                #if DEBUG
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
                    completion(nil, statusCode, JSONError.parse("Could not parse the data as JSON"))
                }
            } // End of dispatched block
        }
        /* 4. Start the request */
        task?.resume()
    }

    /// Creates a URL with specific specifications
    ///
    /// - Parameters:
    ///   - method: The method of the URL
    ///   - parameters: Query parameters
    /// - Returns: The new URL
    private func getURL(method: String, parameters: [String: Any]?) -> URL {
        var components = URLComponents()
        components.scheme = API.Scheme
        components.host = API.Host
        components.path = method

        if let parameters = parameters {
            components.queryItems = []
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

    /// Creates a URL request with specific specifications
    ///
    /// - Parameters:
    ///   - url: The base URL
    ///   - requestType: Type of http request ("GET", "POST", "PUT", "DELETE" etc.)
    ///   - headers: Additional http headers to include in the URL request
    /// - Returns: The new URL Request
    private func getURLRequest(url: URL, requestType: String, headers: [String: String]?) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = requestType
        request.allHTTPHeaderFields = headers
        return request
    }

    /// Authenticate an user with given credentials
    ///
    /// - Parameters:
    ///   - username: Authentication username
    ///   - password: Authentication password
    ///   - completion: The block called after the server has responded
    ///   - token: Authentication token provided by the API server
    ///   - error: The error occurred in the network request, nil for no error.
    func authenticate(username: String, password: String, completion: @escaping(_ token: String?, _ error: Error?) -> Void) {
        let method = Methods.Token
        let headers = DefaultHeaders.PostHeaders
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

    /// Revokes an authentiation token
    ///
    /// - Parameters:
    ///   - token: Token to revoke
    ///   - completion: The block called after the server has responded
    ///   - statusCode: The statusCode of the http request
    ///   - error: The error occurred in the network request, nil for no error.
    func revokeAuthentication(for token: String, completion: @escaping(_ statusCode: Int?, _ error: Error?) -> Void) {
        let method = Methods.Token
        let headers: [String: String] = ["Accept": "*/*", HeadersKeys.Authorization: "Token \(token)"]

        networkTask(requestType: "DELETE", method: method, headers: headers, json: nil, parameters: nil) { _, statusCode, error in
            guard error == nil else {
                completion(nil, Authentication.revoke("There was an error at revoke token API request."))
                return
            }
            completion(statusCode, nil)
        }
    }

    /// Gets the user information
    ///
    /// - Parameters:
    ///   - token: autentication token for requested user
    ///   - completion: The block called after the server has responded
    ///   - response: Returned tuple which contains the firstname and lastname of the user
    ///   - error: The error occurred in the network request, nil for no error.
    func getUserInfo(for token: String, completion: @escaping(_ response: (firstName: String, lastName: String)?, _ error: Error?) -> Void) {

        let method = Methods.User
        let headers: [String: String] = ["Accept": "*/*", HeadersKeys.Authorization: "Token \(token)"]

        networkTask(requestType: "GET", method: method, headers: headers, json: nil, parameters: nil) { jsonData, statusCode, error in

            guard error == nil else {
                completion(nil, error)
                return
            }

            guard statusCode != nil && statusCode == 200 else {
                completion(nil, NetworkingError.wrongStatus("Wrong status \(statusCode!) while receiving user info request."))
                return
            }

            guard let json = jsonData as? [String: String],
                let firstName = json["firstName"],
                let lastName = json["lastName"] else {
                    completion(nil, JSONError.parse("Could not parse json response for user info request."))
                    return
            }

            completion((firstName, lastName), nil)
        }
    }

    /// Gets the locations in the Cloud storage
    ///
    /// - Parameters:
    ///   - completion: The block called after the server has responded
    ///   - mounts: Returned content as an array of locations
    ///   - error: The error occurred in the network request, nil for no error.
    func getMounts(completion: @escaping(_ mounts: [Mount]?, _ error: Error?) -> Void) {
        let method = Methods.Mounts
        var headers = DefaultHeaders.GetHeaders
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token!)"

        networkTask(requestType: "GET", method: method, headers: headers, json: nil, parameters: nil) { data, _, error in

            guard error == nil else {
                completion(nil, error!)
                return
            }

            guard let dict = data as? [String: Any],
                let mountsList = dict["mounts"] as? [Any]
                else {
                    completion(nil, JSONError.parse("Could not parse JSON"))
                    return
            }

            let mounts = mountsList.flatMap { Mount(JSON: $0) }

            completion(mounts, nil)

        }
    }

    /// Gets the bookmarks saved by the user
    ///
    /// - Parameters:
    ///   - completion: The block called after the server has responded
    ///   - bookmarks: Returned content as an array of bookmarks
    ///   - error: The error occurred in the network request, nil for no error.
    func getBookmarks(completion: @escaping(_ bookmarks: [Bookmark]?, _ error: Error?) -> Void) {

        let method = Methods.UserBookmarks

        var headers = DefaultHeaders.GetHeaders
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token!)"

        networkTask(requestType: "GET", method: method, headers: headers, json: nil, parameters: nil) { json, _, error in
            guard error == nil else {
                completion(nil, error!)
                return
            }

            guard let dict = json as? [String: Any],
                let bookmarkJSONArray = dict["bookmarks"] as? [[String: Any]] else {
                completion(nil, JSONError.parse("Could not parse bookmarks response"))
                return
            }

            let bookmarks = bookmarkJSONArray.flatMap { Bookmark(JSON: $0) }
            completion(bookmarks, nil)
        }
    }

    /// Gets the content of nodes of a location in the Cloud storage
    ///
    /// - Parameters:
    ///   - location: The location to get the content
    ///   - completion: The block called after the server has responded
    ///   - result: Returned content as an array of nodes
    ///   - error: The error occurred in the network request, nil for no error.
    func getBundle(for node: Node, completion: @escaping(_ nodes: [Node]?, _ error: Error?) -> Void) {

        let nodeLocation = node.location

        let method = Methods.Bundle.replacingOccurrences(of: "{id}", with: nodeLocation.mount.id)

        var headers = DefaultHeaders.GetHeaders
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token!)"

        let parameters = [ParametersKeys.Path: nodeLocation.path]

        networkTask(requestType: "GET", method: method, headers: headers, json: nil, parameters: parameters) { data, statusCode, error in

            guard error == nil else {
                completion(nil, error!)
                return
            }

            guard statusCode != 400 else {
                let message = NSLocalizedString("Location is no longer available!", comment: "")
                completion(nil, NetworkingError.wrongStatus(message))
                return
            }

            guard let dict = data as? [String: Any],
                let nodesList = dict["files"] as? [[String: Any]] else {
                    completion(nil, JSONError.parse("Could not parse data"))
                    return
            }

            let content = nodesList.flatMap { Node(JSON: $0, parentLocation: nodeLocation) }

            completion(content, nil)
        }
    }

    /// Starts the download of a file
    ///
    /// - Parameters:
    ///   - location: Location of the file
    ///   - delegate: The object delegate which will handle the events while and after downloading
    /// - Returns: The URL session for the download
    func startDownloadFile(for node: ContentItem, delegate: AnyObject) -> URLSession {

        // create the special session with custom delegate for download task
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: delegate as? ContentViewController, delegateQueue: nil)

        // prepare the method string for download file by inserting the current mount
        let method =  Methods.FilesGet.replacingOccurrences(of: "{id}", with: node.location.mount.id)

        // prepare the query parameter path with the current File path
        let parameters = [ParametersKeys.Path: node.location.path]

        // create url from method and parameters
        let url = DigiClient.shared.getURL(method: method, parameters: parameters)

        // create url request with the current token in the HTTP headers
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Token " + DigiClient.shared.token!, forHTTPHeaderField: "Authorization")

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
    func rename(node: Node, with name: String, completion: @escaping(_ statusCode: Int?, _ error: Error?) -> Void) {
        // prepare the method string for rename the node by inserting the current mount
        let method = Methods.FilesRename.replacingOccurrences(of: "{id}", with: node.location.mount.id)

        // prepare headers
        var headers = DefaultHeaders.PutHeaders
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token!)"

        // prepare parameters (path of the node to be renamed
        let parameters = [ParametersKeys.Path: node.location.path]

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
    func delete(node: Node, completion: @escaping(_ statusCode: Int?, _ error: Error?) -> Void) {
        // prepare the method string for rename the node by inserting the current mount
        let method = Methods.FilesRemove.replacingOccurrences(of: "{id}", with: node.location.mount.id)

        // prepare headers
        var headers = DefaultHeaders.DelHeaders
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token!)"

        // prepare parameters (node path to be renamed
        let parameters = [ParametersKeys.Path: node.location.path]

        networkTask(requestType: "DELETE", method: method, headers: headers, json: nil, parameters: parameters) { (_, statusCode, error) in
            completion(statusCode, error)
        }
    }

    /// Create a node of type folder
    ///
    /// - Parameters:
    ///   - node: Node location in which the folder is created
    ///   - name: Folder name
    ///   - completion: The block called after the server has responded
    ///   - statusCode: Returned network request status code
    ///   - error: The error occurred in the network request, nil for no error.
    func createDirectory(in node: Node, with name: String, completion: @escaping(_ statusCode: Int?, _ error: Error?) -> Void) {
        // prepare the method string for create new folder
        let method = Methods.FilesFolder.replacingOccurrences(of: "{id}", with: node.location.mount.id)

        // prepare headers
        var headers = DefaultHeaders.PostHeaders
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token!)"

        // prepare parameters
        let parameters = [ParametersKeys.Path: node.location.path]

        // prepare new folder name in request body
        let jsonBody = [DataJSONKeys.folderName: name]

        networkTask(requestType: "POST", method: method, headers: headers, json: jsonBody, parameters: parameters) { (_, statusCode, error) in
            completion(statusCode, error)
        }
    }

    /// Search for files or folders
    ///
    /// - Parameters:
    ///   - parameters: search parameters
    ///   - completion: The block called after the server has responded
    ///   - results: An array containing the search hits.
    ///   - error: The error occurred in the network request, nil for no error.
    func search(parameters: [String: String], completion: @escaping (_ nodeHits: [NodeHit]?, _ error: Error?) -> Void) {
        let method = Methods.Search

        var headers = DefaultHeaders.GetHeaders
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token!)"

        networkTask(requestType: "GET", method: method, headers: headers, json: nil, parameters: parameters) { json, _, error in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let json = json as? [String: Any],
                let hitsJSON = json["hits"] as? [[String: Any]],
                let mountsJSON = json["mounts"] as? [String: Any]
                else {
                    completion(nil, JSONError.parse("Couldn't parse the json to get the hits and mounts from search results."))
                    return
            }

            let results = hitsJSON.flatMap { NodeHit(hitsJSON: $0, mountsJSON: mountsJSON ) }

            completion(results, nil)
        }
    }

    /// Calculates information from Dictionary content (JSON folder tree)
    ///
    /// - Parameter parent: parent folder
    /// - Returns: return tuple with (size of child, number of files, number of folders)
    private func calculateNodeInfo(_ parent: [String: Any]) -> FolderInfo {
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
                let childInfo = calculateNodeInfo(child)
                info.size += childInfo.size
                info.files += childInfo.files
                info.folders += childInfo.folders
            }
        }
        return info
    }

    /// Get information about a folder
    ///
    /// - Parameters:
    ///   - location: The location of which we get the information
    ///   - completion: The block called after the server has responded
    ///   - info: Tuple containing size, number of files and number of folders
    ///   - error: The error occurred in the network request, nil for no error.
    func getDirectoryInfo(for node: Node, completion: @escaping(_ info: FolderInfo?, _ error: Error?) -> Void) {

        // CHeck if node is a directory
        guard node.type == "dir" else {
            completion(nil, NSError(domain: "Bad input", code: 400, userInfo: nil))
            return
        }

        let method = Methods.FilesTree.replacingOccurrences(of: "{id}", with: node.location.mount.id)

        var headers = DefaultHeaders.GetHeaders
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token!)"

        let parameters = [ParametersKeys.Path: node.location.path]

        networkTask(requestType: "GET", method: method, headers: headers, json: nil, parameters: parameters) { (json, _, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let json = json as? [String: Any] else {
                completion(nil, nil)
                return
            }

            var info = self.calculateNodeInfo(json)
            info.folders -= 1

            // Subtracting 1 because the root folder is also counted
            completion(info, nil)
        }
    }

    /// Send a request to DIGI API to copy or move a node
    ///
    /// - Parameters:
    ///   - node:              Source node
    ///   - to:                Destination location
    ///   - action:            Action Type, expected ActionType.move or ActionType.copy
    ///   - completion:        Function to handle the status code and error response
    ///   - statusCode:        Returned HTTP request Status Code
    ///   - error:             Networking error (nil if no error)
    func copyOrMove(node: Node, to: Location, action: ActionType, completion: @escaping (_ statusCode: Int?, _ error: Error?) -> Void) {

        var method: String

        let nodeLocation = node.location

        switch action {
        case .copy:
            method = Methods.FilesCopy.replacingOccurrences(of: "{id}", with: nodeLocation.mount.id)
        case .move:
            method = Methods.FilesMove.replacingOccurrences(of: "{id}", with: nodeLocation.mount.id)
        default:
            return
        }

        var headers = DefaultHeaders.PutHeaders
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token!)"

        let parameters = [ParametersKeys.Path: nodeLocation.path]

        let json: [String: String] = ["toMountId": to.mount.id, "toPath": to.path]

        networkTask(requestType: "PUT", method: method, headers: headers, json: json, parameters: parameters) { (_, statusCode, error) in
            completion(statusCode, error)
        }
    }

    /// Get the download/upload link for a location
    ///
    /// - Parameters:
    ///   - node:        Source node
    ///   - type:        Link type (.download or .upload)
    ///   - completion:  Function to handle the status code and error response
    ///   - link:        Returned Link
    ///   - error:       Networking error (nil if no error)
    func getLink(for node: Node, type: LinkType, completion: @escaping (_ link: Any?, _ error: Error?) -> Void) {

        let method = Methods.Links
            .replacingOccurrences(of: "{mountId}", with: node.location.mount.id)
            .replacingOccurrences(of: "{linkType}", with: type.rawValue)

        var headers = DefaultHeaders.PostHeaders
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token!)"

        let json = ["path": node.location.path]

        networkTask(requestType: "POST", method: method, headers: headers, json: json, parameters: nil) { json, _, error in

            if let error = error {
                completion(nil, error)
                return
            }

            switch type {
            case .download:
                guard let link = Link(JSON: json) else {
                    completion(nil, JSONError.parse("Could not parce the JSON"))
                    return
                }
                completion(link, nil)

            case .upload:
                guard let receiver = Receiver(JSON: json) else {
                    completion(nil, JSONError.parse("Could not parce the JSON"))
                    return
                }
                completion(receiver, nil)
            }
        }
    }

    /// Reset link (download/upload) password
    ///
    /// - Parameters:
    ///   - node:        Source node
    ///   - linkId:      Link id
    ///   - type:        Link type (.download or .upload)
    ///   - completion:  Function to handle the status code and error response
    ///   - link:        Returned Link
    ///   - error:       Networking error (nil if no error)
    func resetLinkPassword(node: Node, linkId: String, type: LinkType, completion: @escaping (_ link: Any?, _ error: Error?) -> Void ) {

        let method = Methods.LinkResetPassword
            .replacingOccurrences(of: "{mountId}", with: node.location.mount.id)
            .replacingOccurrences(of: "{linkType}", with: type.rawValue)
            .replacingOccurrences(of: "{linkId}", with: linkId)

        var headers = DefaultHeaders.GetHeaders
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token!)"

        networkTask(requestType: "PUT", method: method, headers: headers, json: nil, parameters: nil) { json, statusCode, error in

            if let error = error {
                completion(nil, error)
                return
            }

            guard statusCode == 200 else {
                completion(nil, NetworkingError.wrongStatus("Status is different than 200!"))
                return
            }

            switch type {
            case .download:
                guard let link = Link(JSON: json) else {
                    completion(nil, JSONError.parse("Could not parce the JSON"))
                    return
                }
                completion(link, nil)

            case .upload:
                guard let receiver = Receiver(JSON: json) else {
                    completion(nil, JSONError.parse("Could not parce the JSON"))
                    return
                }
                completion(receiver, nil)
            }
        }
    }

    /// Remove link (download/upload) password
    ///
    /// - Parameters:
    ///   - node:        Source node
    ///   - linkId:      Link id
    ///   - type:        Link type (.download or .upload)
    ///   - completion:  Function to handle the status code and error response
    ///   - link:        Returned Link (Link or Receiver)
    ///   - error:       Networking error (nil if no error)
    func removeLinkPassword(node: Node, linkId: String, type: LinkType, completion: @escaping (_ link: Any?, _ error: Error?) -> Void ) {

        let method = Methods.LinkRemovePassword
            .replacingOccurrences(of: "{mountId}", with: node.location.mount.id)
            .replacingOccurrences(of: "{linkType}", with: type.rawValue)
            .replacingOccurrences(of: "{linkId}", with: linkId)

        var headers = DefaultHeaders.DelHeaders
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token!)"

        networkTask(requestType: "DELETE", method: method, headers: headers, json: nil, parameters: nil) { json, statusCode, error in

            if let error = error {
                completion(nil, error)
                return
            }

            guard statusCode == 200 else {
                completion(nil, NetworkingError.wrongStatus("Status is different than 200!"))
                return
            }

            switch type {
            case .download:
                guard let link = Link(JSON: json) else {
                    completion(nil, JSONError.parse("Could not parce the JSON"))
                    return
                }
                completion(link, nil)

            case .upload:
                guard let receiver = Receiver(JSON: json) else {
                    completion(nil, JSONError.parse("Could not parce the JSON"))
                    return
                }
                completion(receiver, nil)
            }
        }
    }

    /// Set link (download/upload) custom short URL
    ///
    /// - Parameters:
    ///   - node:        Source node
    ///   - linkId:      Link id
    ///   - type:        Link type (.download or .upload)
    ///   - hash:        custom hash of the url "http://s.go.ro/hash"
    ///   - completion:  Function to handle the status code and error response
    ///   - link:        Returned Link (Link or Receiver)
    ///   - error:       Networking error (nil if no error)
    func setLinkCustomShortUrl(node: Node, linkId: String, type: LinkType, hash: String,
                               completion: @escaping (_ link: Any?, _ error: Error?) -> Void ) {

        let method = Methods.LinkCustomURL
            .replacingOccurrences(of: "{mountId}", with: node.location.mount.id)
            .replacingOccurrences(of: "{linkType}", with: type.rawValue)
            .replacingOccurrences(of: "{linkId}", with: linkId)

        var headers = DefaultHeaders.PutHeaders
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token!)"

        let json = ["hash": hash]

        networkTask(requestType: "PUT", method: method, headers: headers, json: json, parameters: nil) { json, statusCode, error in

            if let error = error {
                completion(nil, error)
                return
            }

            if statusCode == 409 {
                completion(nil, NetworkingError.wrongStatus("This shortURL already is alocated"))
                return
            }
            guard statusCode == 200 else {
                completion(nil, NetworkingError.wrongStatus("Status is different than 200!"))
                return
            }

            switch type {
            case .download:
                guard let link = Link(JSON: json) else {
                    completion(nil, JSONError.parse("Could not parce the JSON"))
                    return
                }
                completion(link, nil)

            case .upload:
                guard let receiver = Receiver(JSON: json) else {
                    completion(nil, JSONError.parse("Could not parce the JSON"))
                    return
                }
                completion(receiver, nil)
            }
        }
    }

    /// Set reciever link alert status
    ///
    /// - Parameters:
    ///   - alert:       true for email notifications
    ///   - node:        Sourrce node
    ///   - linkId:      Link id
    ///   - completion:  Function to handle the status code and error response
    ///   - link:        Returned Receiver with alert property updated
    ///   - error:       Networking error (nil if no error)
    func setReceiverAlert(_ alert: Bool, node: Node, linkId: String, completion: @escaping (_ receiver: Receiver?, _ error: Error?) -> Void ) {

        let method = Methods.LinkSetAlert
            .replacingOccurrences(of: "{mountId}", with: node.location.mount.id)
            .replacingOccurrences(of: "{linkId}", with: linkId)

        var headers = DefaultHeaders.PutHeaders
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token!)"

        let json = ["alert": alert]

        networkTask(requestType: "PUT", method: method, headers: headers, json: json, parameters: nil) { json, statusCode, error in

            if let error = error {
                completion(nil, error)
                return
            }

            guard statusCode == 200 else {
                completion(nil, NetworkingError.wrongStatus("Status is different than 200!"))
                return
            }

            guard let receiver = Receiver(JSON: json) else {
                completion(nil, JSONError.parse("Could not parce the JSON"))
                return
            }

            completion(receiver, nil)
        }
    }

    /// Set link validity
    ///
    /// - Parameters:
    ///   - node:        Source node
    ///   - type:        Link type (.download or .upload)
    ///   - linkId:      Link id
    ///   - validTo:     timeIntervalSince1970 (seconds)
    ///   - completion:  Function to handle the status code and error response
    ///   - link:        Returned link with validity updated
    ///   - error:       Networking error (nil if no error)
    func setLinkCustomValidity(node: Node, type: LinkType, linkId: String, validTo: TimeInterval,
                               completion: @escaping (_ link: Any?, _ error: Error?) -> Void ) {

        let method = Methods.LinkValidity
            .replacingOccurrences(of: "{mountId}", with: node.location.mount.id)
            .replacingOccurrences(of: "{linkType}", with: type.rawValue)
            .replacingOccurrences(of: "{linkId}", with: linkId)

        var headers = DefaultHeaders.PutHeaders
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token!)"

        let json = ["validTo": validTo * 1000]

        networkTask(requestType: "PUT", method: method, headers: headers, json: json, parameters: nil) { json, statusCode, error in

            if let error = error {
                completion(nil, error)
                return
            }

            guard statusCode == 200 else {
                completion(nil, NetworkingError.wrongStatus("Status is different than 200!"))
                return
            }

            switch type {
            case .download:
                guard let link = Link(JSON: json) else {
                    completion(nil, JSONError.parse("Could not parce the JSON"))
                    return
                }
                completion(link, nil)

            case .upload:
                guard let receiver = Receiver(JSON: json) else {
                    completion(nil, JSONError.parse("Could not parce the JSON"))
                    return
                }
                completion(receiver, nil)
            }
        }
    }

    /// Delete link (download/upload) password
    ///
    /// - Parameters:
    ///   - node:        Source node
    ///   - type:        Link type (.download or .upload)
    ///   - linkId:      Link Id
    ///   - completion:  Function to handle the status code and error response
    ///   - error:       Networking error (nil if no error)
    func deleteLink(node: Node, type: LinkType, linkId: String, completion: @escaping (_ error: Error?) -> Void ) {

        let method = Methods.LinkDelete
            .replacingOccurrences(of: "{mountId}", with: node.location.mount.id)
            .replacingOccurrences(of: "{linkType}", with: type.rawValue)
            .replacingOccurrences(of: "{linkId}", with: linkId)

        var headers = DefaultHeaders.DelHeaders
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token!)"

        networkTask(requestType: "DELETE", method: method, headers: headers, json: nil, parameters: nil) { _, statusCode, error in

            if let error = error {
                completion(error)
                return
            }

            guard statusCode == 204 else {
                completion(NetworkingError.wrongStatus("Status is different than 204!"))
                return
            }

            completion(nil)
        }
    }

}
