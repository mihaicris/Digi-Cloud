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

    static let shared: DigiClient = DigiClient()

    var session: URLSession?

    var task: URLSessionDataTask?

    private var token: String {

        guard let token = try? loggedAccount.readToken() else {

            AppSettings.showErrorMessageAndCrash(
                title: NSLocalizedString("Error reading account from Keychain", comment: ""),
                subtitle: NSLocalizedString("The app will now close", comment: "")
            )
            return ""
        }

        return token

    }

    var loggedAccount: Account!

    // MARK: - Initializers and Deinitializers

    private init() {
        renewSession()
    }

    // MARK: - Helper Functions

    func renewSession() {
        session?.invalidateAndCancel()
        let config = URLSessionConfiguration.default

        #if DEBUG
            config.timeoutIntervalForRequest = 10
            config.timeoutIntervalForResource = 10
        #else
            config.timeoutIntervalForRequest = 60
            config.timeoutIntervalForResource = 60
        #endif

        config.allowsCellularAccess = AppSettings.allowsCellularAccess
        session = URLSession(configuration: config)
    }

    // MARK: - Main Network Call

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
    func networkTask(requestType: RequestType,
                     method: String,
                     headers: [String: String]?,
                     json: [String: Any]? = nil,
                     data: Data? = nil,
                     parameters: [String: String]?,
                     withoutRequestSerialization: Bool = false,
                     withoutSerialization: Bool = false,
                     completion: @escaping(_ data: Any?, _ response: Int?, _ error: Error?) -> Void) {

        #if DEBUG
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        #endif

        /* 1. Build the URL, Configure the request */
        let url = self.getURL(method: method, parameters: parameters)

        var request = self.getURLRequest(url: url, requestType: requestType.rawValue, headers: headers)

        // add json object to request
        if let json = json {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: json, options: [])
            } catch {
                completion(nil, nil, JSONError.parse("Could not convert json into data!"))
            }
        } else if let data = data {
            request.httpBody = data
        }

        /* 2. Make the request */
        task = session?.dataTask(with: request) { (data, response, error ) in

            DispatchQueue.main.async {

                #if DEBUG
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                #endif

                /* GUARD: Was there an error? */
                guard error == nil else {

                    /* TODO: Implement error codes:
                    
                    -999  = Task was cancelled
                    -1001 = The request timed out.
                    -1009 = The internet connection appears to be offline
                     
                    */

                    let nserror = error! as NSError
                    LogNSError(nserror)

                    switch nserror.code {

                        case -999:
                            // Don't call completion if request was cancelled.
                            break
                        case -1001:
                            completion(nil, nil, NetworkingError.requestTimedOut(NSLocalizedString("The request timed out.", comment: "")))
                        case -1009:
                            completion(nil, nil, NetworkingError.internetOffline(NSLocalizedString("The internet appears to be offline.", comment: "")))
                    default:
                        completion(nil, nil, error)
                    }
                    return
                }

                /* GUARD: Did we get a statusCode? */
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                    completion(nil, nil, NetworkingError.get("There was an error with your request: \(error!.localizedDescription)"))
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

                if withoutSerialization {
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

    private func photoDataToFormData(data: Data, boundary: String, fileName: String) -> Data {
        let fullData = NSMutableData()

        // 1 - Boundary should start with --
        let lineOne = "--" + boundary + "\r\n"
        fullData.append(lineOne.data(using: .utf8, allowLossyConversion: false)!)

        // 2

        let lineTwo = "Content-Disposition: form-data; name=\"image\"; filename=\"" + fileName + "\"\r\n"
        fullData.append(lineTwo.data(using: .utf8, allowLossyConversion: false)!)

        // 3
        let lineThree = "Content-Type: image/png\r\n\r\n"
        fullData.append(lineThree.data(using: .utf8, allowLossyConversion: false)!)

        // 4
        fullData.append(data)

        // 5
        let lineFive = "\r\n"
        fullData.append(lineFive.data(using: .utf8, allowLossyConversion: false)!)

        // 6 - The end. Notice -- at the start and at the end
        let lineSix = "--" + boundary + "--\r\n"
        fullData.append(lineSix.data( using: .utf8, allowLossyConversion: false)!)

        return fullData as Data

    }

    // MARK: - Authentication

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

        networkTask(requestType: .post, method: method, headers: headers, json: jsonBody, parameters: nil) { json, statusCode, error in

            guard error == nil else {
                completion(nil, error)
                return
            }

            if statusCode == 200 {
                if let json = json as? [String: String] {
                    let token  = json["token"]
                    completion(token, nil)
                }
            } else {
                completion(nil, AuthenticationError.login)
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
    func revokeAuthentication(for token: String, completion: @escaping( _ error: Error?) -> Void) {

        let method = Methods.Token
        let headers: [String: String] = ["Accept": "*/*", HeadersKeys.Authorization: "Token \(token)"]

        networkTask(requestType: .delete, method: method, headers: headers, json: nil, parameters: nil) { _, statusCode, error in

            guard error == nil else {
                completion(error)
                return
            }

            guard statusCode == 204 else {
                completion(AuthenticationError.revoke)
                return
            }

            completion(nil)
        }
    }

    // MARK: - Settings

    /// Gets the user information
    ///
    /// - Parameters:
    ///   - token: autentication token for requested user
    ///   - completion: The block called after the server has responded
    ///   - user: Returned user (permissions should be neglected)
    ///   - error: The error occurred in the network request, nil for no error.
    func getUser(forToken token: String, completion: @escaping(_ user: User?, _ error: Error?) -> Void) {

        let method = Methods.User
        let headers: [String: String] = ["Accept": "*/*", HeadersKeys.Authorization: "Token \(token)"]

        networkTask(requestType: .get, method: method, headers: headers, json: nil, parameters: nil) { jsonData, statusCode, error in

            guard error == nil else {
                completion(nil, error)
                return
            }

            guard statusCode == 200 else {
                completion(nil, AuthenticationError.login)
                return
            }

            guard jsonData != nil, let user = User(infoJSON: jsonData) else {
                completion(nil, JSONError.parse("Error parsing USER with JSON data: \(jsonData!)"))
                return
            }

            completion(user, nil)
        }
    }

    func getUserProfileImage(for user: User, completion: @escaping(_ image: UIImage?, _ error: Error?) -> Void) {

        let method = Methods.UserProfileImage.replacingOccurrences(of: "{userId}", with: user.id)
        var headers = DefaultHeaders.GetHeaders
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token)"

        networkTask(requestType: .get, method: method, headers: headers, json: nil, parameters: nil, withoutSerialization: true) { data, statusCode, error in

            guard error == nil else {
                completion(nil, error)
                return
            }

            guard statusCode == 200 else {
                completion(nil, ResponseError.notFound)
                return
            }

            if let data = data as? Data,
                let image = UIImage(data: data) {
                completion(image, nil)
            } else {
                completion(nil, ConversionError.data("Could not retrieve the profile image for user with email \(user.email)"))
            }

        }

    }

    func setUserProfileImage(_ data: Data, completion: @escaping(Error?) -> Void) {

        let method = Methods.UserProfileImageSet
        var headers = [HeadersKeys.Authorization: "Token \(DigiClient.shared.token)"]

        let boundary = "----WebKitFormBoundary\(UUID().uuidString)"

        let fullData = photoDataToFormData(data: data, boundary: boundary, fileName: "profile.png")

        headers["Accept"] = "application/json"
        headers["Content-Type"] = "multipart/form-data; boundary=\(boundary)"
        headers["Content-Length"] = String(fullData.count)

        networkTask(requestType: .post, method: method, headers: headers,
                    data: fullData, parameters: nil, withoutRequestSerialization: true) { _, statusCode, error in

            guard error == nil else {
                completion(error)
                return
            }

            guard statusCode == 200 else {
                completion(ResponseError.notFound)
                return
            }

            completion(nil)
        }
    }

    func updateUserInfo(firstName: String, lastName: String, completion: @escaping(Error?) -> Void) {

        let method = Methods.User
        var headers = DefaultHeaders.PutHeaders
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token)"

        let jsonObject = ["lastName": lastName, "firstName": firstName]

        networkTask(requestType: .put, method: method, headers: headers, json: jsonObject, parameters: nil) { _, statusCode, error in

            guard error == nil else {
                completion(error)
                return
            }

            guard statusCode == 204 else {
                completion(ResponseError.notFound)
                return
            }

            completion(nil)
        }
    }

    func getSecuritySettings() {
        let method = Methods.UserSettingsSec
        var headers = DefaultHeaders.GetHeaders
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token)"

        networkTask(requestType: .get, method: method, headers: headers, json: nil, parameters: nil) { jsonData, statusCode, error in

            guard error == nil else {
                return
            }

            guard statusCode == 200 else {
                return
            }

            guard let jsonDict = jsonData as? [String: Any],
                let downloadLinkAutoPassword  = jsonDict["downloadLinkAutoPassword"] as? Bool,
                let uploadLinkAutoPassword      = jsonDict["uploadLinkAutoPassword"] as? Bool else {
                    return
            }

            AppSettings.shouldPasswordDownloadLink = downloadLinkAutoPassword
            AppSettings.shouldPasswordReceiveLink = uploadLinkAutoPassword
        }
    }

    func setSecuritySettings(shouldPasswordDownloadLink: Bool, shouldPasswordReceiveLink: Bool, completion: @escaping((Error?) -> Void)) {
        let method = Methods.UserSettingsSec
        var headers = DefaultHeaders.PutHeaders
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token)"

        let json: [String: Bool] = ["downloadLinkRequirePassword": false,
                                    "downloadLinkAutoPassword": shouldPasswordDownloadLink,
                                    "uploadLinkRequirePassword": false,
                                    "uploadLinkAutoPassword": shouldPasswordReceiveLink]

        networkTask(requestType: .put, method: method, headers: headers, json: json, parameters: nil) { _, statusCode, error in

            guard error == nil else {
                completion(error)
                return
            }

            guard statusCode == 204 else {
                completion(ResponseError.other)
                return
            }
            completion(nil)
        }
    }

    // MARK: - Bookmarks

    /// Gets the bookmarks saved by the user
    ///
    /// - Parameters:
    ///   - completion: The block called after the server has responded
    ///   - bookmarks: Returned content as an array of bookmarks
    ///   - error: The error occurred in the network request, nil for no error.
    func getBookmarks(completion: @escaping(_ bookmarks: [Bookmark]?, _ error: Error?) -> Void) {

        let method = Methods.UserBookmarks
        var headers = DefaultHeaders.GetHeaders
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token)"

        networkTask(requestType: .get, method: method, headers: headers, json: nil, parameters: nil) { json, statusCode, error in

            guard error == nil else {
                completion(nil, error)
                return
            }

            guard statusCode == 200 else {
                completion(nil, ResponseError.notFound)
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

    /// Set bookmarks
    ///
    /// - Parameters:
    ///   - bookmarks: array of Bookmark type. If Array is empty, all bookmarks will be removed.
    ///   - completion: The block called after the server has responded
    ///   - error: The error returned
    func setBookmarks(bookmarks: [Bookmark], completion: @escaping(_ error: Error?) -> Void) {

        let method = Methods.UserBookmarks
        var headers = DefaultHeaders.PutHeaders
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token)"

        var json: [String: Any] = [:]
        var bookmarksJSON: [[String: String]] = []

        for bookmark in bookmarks {
            var bookmarkJSON: [String: String] = [:]
            bookmarkJSON["path"] = bookmark.path
            bookmarkJSON["mountId"] = bookmark.mountId
            bookmarksJSON.append(bookmarkJSON)
        }

        json["bookmarks"] = bookmarksJSON

        networkTask(requestType: .put, method: method, headers: headers, json: json, parameters: nil) { _, statusCode, error in

            guard error == nil else {
                completion(error)
                return
            }

            guard statusCode == 204 else {
                completion(ResponseError.notFound)
                return
            }

            completion(nil)
        }
    }

    /// Add bookmark
    ///
    /// - Parameters:
    ///   - bookmark: Bookmark to add.
    ///   - completion: The block called after the server has responded
    ///   - error: The error returned
    func addBookmark(bookmark: Bookmark, completion: @escaping(_ error: Error?) -> Void) {

        let method = Methods.UserBookmarks
        var headers = DefaultHeaders.PostHeaders
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token)"

        let json: [String: String] = ["path": bookmark.path, "mountId": bookmark.mountId]

        networkTask(requestType: .post, method: method, headers: headers, json: json, parameters: nil) { _, statusCode, error in

            guard error == nil else {
                completion(error)
                return
            }

            guard statusCode == 201 else {
                completion(ResponseError.notFound)
                return
            }

            completion(nil)
        }
    }

    /// Remove bookmark
    ///
    /// - Parameters:
    ///   - bookmark: Bookmark to remove.
    ///   - completion: The block called after the server has responded
    ///   - error: The error returned
    func removeBookmark(bookmark: Bookmark, completion: @escaping(_ error: Error?) -> Void) {

        let method = Methods.UserBookmarks
        var headers = DefaultHeaders.DelHeaders
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token)"

        var parameters: [String: String] = [:]
        parameters["path"] = bookmark.path
        parameters["mountId"] = bookmark.mountId

        networkTask(requestType: .delete, method: method, headers: headers, json: nil, parameters: parameters) { _, statusCode, error in

            guard error == nil else {
                completion(error)
                return
            }

            guard statusCode == 204 else {
                completion(ResponseError.notFound)
                return
            }

            completion(nil)
        }
    }

    // MARK: - Mounts

    /// Gets the locations in the Cloud storage
    ///
    /// - Parameters:
    ///   - completion: The block called after the server has responded
    ///   - mounts: Returned content as an array of locations
    ///   - error: The error occurred in the network request, nil for no error.
    func getMounts(completion: @escaping(_ mounts: [Mount]?, _ error: Error?) -> Void) {

        let method = Methods.Mounts
        var headers = DefaultHeaders.GetHeaders
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token)"

        networkTask(requestType: .get, method: method, headers: headers, json: nil, parameters: nil) { data, statusCode, error in

            guard error == nil else {
                completion(nil, error)
                return
            }

            guard statusCode == 200 else {
                completion(nil, ResponseError.notFound)
                return
            }

            guard let dict = data as? [String: Any],
                let mountsList = dict["mounts"] as? [Any]
                else {
                    completion(nil, JSONError.parse("Could not parse JSON data for Mounts"))
                    return
            }

            let mounts = mountsList.flatMap { Mount(JSON: $0) }
            completion(mounts, nil)
        }
    }

    /// Create submount
    ///
    /// - Parameters:
    ///   - location: Root Location of the mount
    ///   - withName: Mount name
    ///   - completion: completion with new mount information
    ///   - mount: Returned Mount
    ///   - error: The error occurred in the network request, nil for no error.
    func createSubmount(at location: Location, withName: String, completion: @escaping( _ mount: Mount?, _ error: Error?) -> Void) {

        let method = Methods.MountCreate.replacingOccurrences(of: "{id}", with: location.mount.id)
        var headers = DefaultHeaders.PostHeaders
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token)"

        let json: [String: String] = ["path": location.path, "name": withName]

        networkTask(requestType: .post, method: method, headers: headers, json: json, parameters: nil) { json, statusCode, error in

            guard error == nil else {
                completion(nil, error)
                return
            }

            guard statusCode == 201 else {
                completion(nil, ResponseError.notFound)
                return
            }

            guard let mount = Mount(JSON: json) else {
                completion(nil, JSONError.parse("Error parsing Mount JSON."))
                return
            }

            completion(mount, nil)
        }
    }

    /// Get Mount Details
    ///
    /// - Parameters:
    ///   - id: Mount Id
    ///   - completion: The block called after the server has responded
    ///   - mount: Returned Mount
    ///   - error: The error occurred in the network request, nil for no error.
    func getMountDetails(for mount: Mount, completion: @escaping(_ mount: Mount?, _ error: Error?) -> Void) {

        let method = Methods.MountEdit.replacingOccurrences(of: "{id}", with: mount.id)
        var headers = DefaultHeaders.GetHeaders
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token)"

        networkTask(requestType: .get, method: method, headers: headers, json: nil, parameters: nil) { (json, statusCode, error) in

            guard error == nil else {
                completion(nil, error)
                return
            }

            guard statusCode == 200 else {
                completion(nil, ResponseError.notFound)
                return
            }

            guard let mount = Mount(JSON: json) else {
                completion(nil, JSONError.parse("Error parsing Mount JSON."))
                return
            }

            completion(mount, nil)
        }
    }

    func editMount(for mount: Mount, newName: String, completion: @escaping(_ error: Error?) -> Void) {

        let method = Methods.MountEdit.replacingOccurrences(of: "{id}", with: mount.id)
        var headers = DefaultHeaders.PutHeaders
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token)"

        let json = ["name": newName]

        networkTask(requestType: .put, method: method, headers: headers, json: json, parameters: nil) { (_, statusCode, error) in

            guard error == nil else {
                completion(error)
                return
            }

            guard statusCode == 204 else {
                completion(ResponseError.notFound)
                return
            }

            completion(nil)
        }
    }

    /// Mount operations
    ///
    /// - Parameters:
    ///   - mount: A mount type
    ///   - operation: An UserOperation type
    ///   - user: An user type
    func updateMount(mount: Mount, operation: MountUserUpdateOperation, user: User,
                     completion: @escaping(_ user: User?, _ error: Error?) -> Void) {

        var requestType: RequestType
        var headers: [String: String]

        var method: String
        var json: [String: Any]? = [:]
        switch operation {

        case .add:
            requestType = .post
            headers = DefaultHeaders.PostHeaders
            method = Methods.UserAdd.replacingOccurrences(of: "{id}", with: mount.id)
            json?["email"] = user.email
            json?["permissions"] = user.permissions.json

        case .updatePermissions:
            requestType = .put
            headers = DefaultHeaders.PutHeaders
            method = Methods.UserChange.replacingOccurrences(of: "{mountId}", with: mount.id)
                .replacingOccurrences(of: "{userId}", with: user.id)
            json?["permissions"] = user.permissions.json

        case .remove:
            requestType = .delete
            headers = DefaultHeaders.DelHeaders
            method = Methods.UserChange.replacingOccurrences(of: "{mountId}", with: mount.id)
                .replacingOccurrences(of: "{userId}", with: user.id)
            json = nil
        }

        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token)"

        networkTask(requestType: requestType,
                    method: method,
                    headers: headers,
                    json: json,
                    parameters: nil,
                    withoutSerialization: operation == .updatePermissions || operation == .remove) { json, statusCode, error in

            guard error == nil else {
                completion(nil, error)
                return
            }

            switch operation {

            case .add:
                guard statusCode == 201 else {
                    completion(nil, ResponseError.notFound)
                    return
                }

                guard let user = User(JSON: json) else {
                    completion(nil, JSONError.parse("Error parsing User JSON."))
                    return
                }
                completion(user, nil)

            case .updatePermissions, .remove:
                guard statusCode == 204 else {
                    completion(nil, ResponseError.notFound)
                    return
                }

                completion(nil, nil)
            }
        }
    }

    /// Delete a mount
    ///
    /// - Parameters:
    ///   - mount: Mount to be deleted
    ///   - completion: The block called after the server has responded
    ///   - error: The error occurred in the network request, nil for no error.
    func deleteMount(_ mount: Mount, completion: @escaping (_ error: Error?) -> Void) {

        let method = Methods.MountEdit.replacingOccurrences(of: "{id}", with: mount.id)
        var headers = DefaultHeaders.DelHeaders
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token)"

        networkTask(requestType: .delete, method: method, headers: headers, json: nil, parameters: nil) { (_, statusCode, error) in

            guard error == nil else {
                completion(error)
                return
            }

            guard statusCode == 204 else {
                completion(ResponseError.notFound)
                return
            }

            completion(nil)
        }
    }

    // MARK: - Files

    func fileInfo(atLocation location: Location, completion: @escaping((Node?, Error?) -> Void)) {

        let method = Methods.FilesInfo.replacingOccurrences(of: "{mountId}", with: location.mount.id)
        var headers = DefaultHeaders.GetHeaders
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token)"

        let parameters = ["path": location.path]

        networkTask(requestType: .get, method: method, headers: headers, json: nil, parameters: parameters) { (jsonData, statusCode, error) in

            guard error == nil else {
                completion(nil, error)
                return
            }

            guard statusCode == 200 else {
                completion(nil, ResponseError.notFound)
                return
            }

            guard let node = Node(JSON: jsonData) else {
                completion(nil, JSONError.parse("Error parsing Node JSON."))
                return
            }

            completion(node, nil)
        }
    }

    /// Create a node of type directory
    ///
    /// - Parameters:
    ///   - location: Location where the directory will be created
    ///   - name: directory name
    ///   - completion: The block called after the server has responded
    ///   - statusCode: Returned network request status code
    ///   - error: The error occurred in the network request, nil for no error.
    func createDirectory(at location: Location, named: String, completion: @escaping(_ statusCode: Int?, _ error: Error?) -> Void) {

        let method = Methods.FilesDirectory.replacingOccurrences(of: "{id}", with: location.mount.id)
        var headers = DefaultHeaders.PostHeaders
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token)"
        let parameters = [ParametersKeys.Path: location.path]
        let jsonBody = [DataJSONKeys.directoryName: named]

        networkTask(requestType: .post, method: method, headers: headers, json: jsonBody, parameters: parameters) { (_, statusCode, error) in

            guard error == nil else {
                completion(nil, error)
                return
            }

            // Handle various statusCodes here
            completion(statusCode, nil)
        }
    }

    /// Starts the download of a file
    ///
    /// - Parameters:
    ///   - location: Location of the file
    ///   - delegate: The object delegate which will handle the events while and after downloading
    /// - Returns: The URL session for the download
    func startDownloadFile(at location: Location, delegate: URLSessionDelegate) -> URLSession {

        // create the special session with custom delegate for download task
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)

        // prepare the method string for download file by inserting the current mount
        let method =  Methods.FilesGet.replacingOccurrences(of: "{id}", with: location.mount.id)

        // prepare the query parameter path with the current File path
        let parameters = [ParametersKeys.Path: location.path]

        // create url from method and parameters
        let url = DigiClient.shared.getURL(method: method, parameters: parameters)

        // create url request with the current token in the HTTP headers
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Token " + DigiClient.shared.token, forHTTPHeaderField: "Authorization")

        // create and start download task
        let downloadTask = session.downloadTask(with: request)
        downloadTask.resume()

        return session
    }

    /// Send a request to DIGI API to copy or move a node
    ///
    /// - Parameters:
    ///   - fromLocation:      Source location
    ///   - toLocation:        Destination location
    ///   - action:            Action Type, expected ActionType.move or ActionType.copy
    ///   - completion:        Function to handle the status code and error response
    ///   - statusCode:        Returned HTTP request Status Code
    ///   - error:             Networking error (nil if no error)
    func copyOrMove(from fromLocation: Location, to toLocation: Location, action: ActionType, completion: @escaping (_ statusCode: Int?, _ error: Error?) -> Void) {

        var method: String

        switch action {
        case .copy:
            method = Methods.FilesCopy.replacingOccurrences(of: "{id}", with: fromLocation.mount.id)
        case .move:
            method = Methods.FilesMove.replacingOccurrences(of: "{id}", with: fromLocation.mount.id)
        default:
            return
        }

        var headers = DefaultHeaders.PutHeaders
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token)"

        let parameters = [ParametersKeys.Path: fromLocation.path]

        let json: [String: String] = ["toMountId": toLocation.mount.id, "toPath": toLocation.path]

        networkTask(requestType: .put, method: method, headers: headers, json: json, parameters: parameters) { (_, statusCode, error) in

            guard error == nil else {
                completion(nil, error)
                return
            }

            // Handle various statusCodes here
            completion(statusCode, nil)
        }
    }

    /// Renames a node
    ///
    /// - Parameters:
    ///   - location: Location of the node to be renamed
    ///   - name: The new name of the node
    ///   - completion: The block called after the server has responded
    ///   - statusCode: Returned network request status code
    ///   - error: The error occurred in the network request, nil for no error.
    func renameNode(at location: Location, with name: String, completion: @escaping(_ statusCode: Int?, _ error: Error?) -> Void) {
        // prepare the method string for rename the node by inserting the current mount
        let method = Methods.FilesRename.replacingOccurrences(of: "{id}", with: location.mount.id)

        // prepare headers
        var headers = DefaultHeaders.PutHeaders
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token)"

        // prepare parameters
        let parameters = [ParametersKeys.Path: location.path]

        // prepare new name in request body
        let jsonBody = ["name": name]

        networkTask(requestType: .put, method: method, headers: headers, json: jsonBody, parameters: parameters) { (_, statusCode, error) in

            guard error == nil else {
                completion(nil, error)
                return
            }

            // Handle various statusCodes here
            completion(statusCode, nil)
        }
    }

    /// Deletes a node (file or directory)
    ///
    /// - Parameters:
    ///   - location: Location of the node
    ///   - completion: The block called after the server has responded
    ///   - statusCode: Returned network request status code
    ///   - error: The error occurred in the network request, nil for no error.
    func deleteNode(at location: Location, completion: @escaping(_ statusCode: Int?, _ error: Error?) -> Void) {

        let method = Methods.FilesRemove.replacingOccurrences(of: "{id}", with: location.mount.id)
        var headers = DefaultHeaders.DelHeaders
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token)"
        let parameters = [ParametersKeys.Path: location.path]

        networkTask(requestType: .delete, method: method, headers: headers, json: nil, parameters: parameters) { (_, statusCode, error) in

            guard error == nil else {
                completion(nil, error)
                return
            }

            // Handle various statusCodes here
            completion(statusCode, nil)
        }
    }

    /// Calculates information from Dictionary content (JSON directory tree)
    ///
    /// - Parameter parent: Parent directory
    /// - Returns: Tuple with (size of child, number of files, number of directories)
    private func calculateNodeInfo(_ parent: [String: Any]) -> DirectoryInfo {
        var info = DirectoryInfo()
        if let childType = parent["type"] as? String, childType == "file" {
            info.files += 1
            if let size = parent["size"] as? Int64 {
                info.size += size
                return info
            }
        }
        if let children = parent["children"] as? [[String: Any]] {
            info.directories += 1
            for child in children {
                let childInfo = calculateNodeInfo(child)
                info.size += childInfo.size
                info.files += childInfo.files
                info.directories += childInfo.directories
            }
        }
        return info
    }

    /// Get information about a directory
    ///
    /// - Parameters:
    ///   - location: The location of which we get the information
    ///   - completion: The block called after the server has responded
    ///   - info: Tuple containing size, number of files and number of directories
    ///   - error: The error occurred in the network request, nil for no error.
    func getDirectoryInfo(at location: Location, completion: @escaping(_ info: DirectoryInfo?, _ error: Error?) -> Void) {

        let method = Methods.FilesTree.replacingOccurrences(of: "{id}", with: location.mount.id)
        var headers = DefaultHeaders.GetHeaders
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token)"
        let parameters = [ParametersKeys.Path: location.path]

        networkTask(requestType: .get, method: method, headers: headers, json: nil, parameters: parameters) { (json, statusCode, error) in

            guard error == nil else {
                completion(nil, error)
                return
            }

            guard statusCode == 200 else {
                completion(nil, ResponseError.notFound)
                return
            }

            guard let json = json as? [String: Any] else {
                completion(nil, JSONError.parse("Could not parse the File Tree JSON data."))
                return
            }

            var info = self.calculateNodeInfo(json)

            // Subtracting 1 because the root directory is also counted
            info.directories -= 1

            completion(info, nil)
        }
    }

    // MARK: - Links

    /// Get the download/upload link for a location
    ///
    /// - Parameters:
    ///   - location:    Location to get a link
    ///   - type:        Link type (.download or .upload)
    ///   - completion:  Function to handle the status code and error response
    ///   - link:        Returned Link
    ///   - error:       Networking error (nil if no error)
    func getLink(for location: Location, type: LinkType, completion: @escaping (_ link: Link?, _ error: Error?) -> Void) {

        let method = Methods.Links
            .replacingOccurrences(of: "{mountId}", with: location.mount.id)
            .replacingOccurrences(of: "{linkType}", with: type.rawValue)
        var headers = DefaultHeaders.PostHeaders
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token)"
        let json = ["path": location.path]

        networkTask(requestType: .post, method: method, headers: headers, json: json, parameters: nil) { json, statusCode, error in

            if let error = error {
                completion(nil, error)
                return
            }

            guard statusCode == 200 || statusCode == 201 else {
                completion(nil, ResponseError.other)
                return
            }

            switch type {
            case .download:
                guard let link = DownloadLink(JSON: json) else {
                    completion(nil, JSONError.parse("Could not parce the JSON data for Link."))
                    return
                }
                completion(link, nil)

            case .upload:
                guard let receiver = UploadLink(JSON: json) else {
                    completion(nil, JSONError.parse("Could not parce the JSON data for Receiver."))
                    return
                }
                completion(receiver, nil)
            }
        }
    }

    func listLinks() {
        // TODO: Implement
    }

    func linkDetails() {
        // TODO: Implement
    }

    /// Set link (download/upload) custom short URL
    ///
    /// - Parameters:
    ///   - mount:       Mount of link
    ///   - linkId:      Link id
    ///   - type:        Link type (.download or .upload)
    ///   - hash:        custom hash of the url "http://s.go.ro/hash"
    ///   - completion:  Function to handle the status code and error response
    ///   - link:        Returned Link
    ///   - error:       Networking error (nil if no error)
    func setLinkCustomShortUrl(mount: Mount, linkId: String, type: LinkType, hash: String,
                               completion: @escaping (_ link: Link?, _ error: Error?) -> Void ) {

        let method = Methods.LinkCustomURL
            .replacingOccurrences(of: "{mountId}", with: mount.id)
            .replacingOccurrences(of: "{linkType}", with: type.rawValue)
            .replacingOccurrences(of: "{linkId}", with: linkId)

        var headers = DefaultHeaders.PutHeaders
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token)"

        let json = ["hash": hash]

        networkTask(requestType: .put, method: method, headers: headers, json: json, parameters: nil) { json, statusCode, error in

            guard error == nil else {
                completion(nil, error)
                return
            }

            guard statusCode == 200 else {
                completion(nil, ResponseError.other)
                return
            }

            switch type {
            case .download:
                guard let link = DownloadLink(JSON: json) else {
                    completion(nil, JSONError.parse("Could not parce the JSON for Link."))
                    return
                }
                completion(link, nil)

            case .upload:
                guard let receiver = UploadLink(JSON: json) else {
                    completion(nil, JSONError.parse("Could not parce the JSON for receiver."))
                    return
                }
                completion(receiver, nil)
            }
        }
    }

    /// Reset link (download/upload) password
    ///
    /// - Parameters:
    ///   - mount:       Mount of link
    ///   - linkId:      Link id
    ///   - type:        Link type (.download or .upload)
    ///   - completion:  Function to handle the status code and error response
    ///   - link:        Returned Link
    ///   - error:       Networking error (nil if no error)
    func setOrResetLinkPassword(mount: Mount, linkId: String, type: LinkType, completion: @escaping (_ link: Link?, _ error: Error?) -> Void ) {

        let method = Methods.LinkResetPassword
            .replacingOccurrences(of: "{mountId}", with: mount.id)
            .replacingOccurrences(of: "{linkType}", with: type.rawValue)
            .replacingOccurrences(of: "{linkId}", with: linkId)

        var headers = DefaultHeaders.GetHeaders
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token)"

        networkTask(requestType: .put, method: method, headers: headers, json: nil, parameters: nil) { json, statusCode, error in

            guard error == nil else {
                completion(nil, error)
                return
            }

            guard statusCode == 200 else {
                completion(nil, ResponseError.other)
                return
            }

            switch type {
            case .download:
                guard let link = DownloadLink(JSON: json) else {
                    completion(nil, JSONError.parse("Could not parce the JSON for Link."))
                    return
                }
                completion(link, nil)

            case .upload:
                guard let receiver = UploadLink(JSON: json) else {
                    completion(nil, JSONError.parse("Could not parce the JSON for Receiver."))
                    return
                }
                completion(receiver, nil)
            }
        }
    }

    /// Remove link (download/upload) password
    ///
    /// - Parameters:
    ///   - mount:       Mount of link
    ///   - linkId:      Link id
    ///   - type:        Link type (.download or .upload)
    ///   - completion:  Function to handle the status code and error response
    ///   - link:        Returned Link
    ///   - error:       Networking error (nil if no error)
    func removeLinkPassword(mount: Mount, linkId: String, type: LinkType, completion: @escaping (_ link: Link?, _ error: Error?) -> Void ) {

        let method = Methods.LinkRemovePassword
            .replacingOccurrences(of: "{mountId}", with: mount.id)
            .replacingOccurrences(of: "{linkType}", with: type.rawValue)
            .replacingOccurrences(of: "{linkId}", with: linkId)

        var headers = DefaultHeaders.DelHeaders
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token)"

        networkTask(requestType: .delete, method: method, headers: headers, json: nil, parameters: nil) { json, statusCode, error in

            guard error == nil else {
                completion(nil, error)
                return
            }

            guard statusCode == 200 else {
                completion(nil, ResponseError.other)
                return
            }

            switch type {
            case .download:
                guard let link = DownloadLink(JSON: json) else {
                    completion(nil, JSONError.parse("Could not parce the JSON for Link."))
                    return
                }
                completion(link, nil)

            case .upload:
                guard let receiver = UploadLink(JSON: json) else {
                    completion(nil, JSONError.parse("Could not parce the JSON for Receiver."))
                    return
                }
                completion(receiver, nil)
            }
        }
    }

    /// Delete link (download/upload) password
    ///
    /// - Parameters:
    ///   - mount:       Mount of link
    ///   - linkId:      Link id
    ///   - type:        Link type (.download or .upload)
    ///   - completion:  Function to handle the status code and error response
    ///   - error:       Networking error (nil if no error)
    func deleteLink(mount: Mount, linkId: String, type: LinkType, completion: @escaping (_ error: Error?) -> Void ) {

        let method = Methods.LinkDelete
            .replacingOccurrences(of: "{mountId}", with: mount.id)
            .replacingOccurrences(of: "{linkType}", with: type.rawValue)
            .replacingOccurrences(of: "{linkId}", with: linkId)

        var headers = DefaultHeaders.DelHeaders
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token)"

        networkTask(requestType: .delete, method: method, headers: headers, json: nil, parameters: nil) { _, statusCode, error in

            guard error == nil else {
                completion(error)
                return
            }

            guard statusCode == 204 else {
                completion(ResponseError.other)
                return
            }

            completion(nil)
        }
    }

    /// Set reciever link alert status
    ///
    /// - Parameters:
    ///   - alert:       true for email notifications
    ///   - mount:       Mount of link
    ///   - linkId:      Link id
    ///   - completion:  Function to handle the status code and error response
    ///   - link:        Returned UploadLink with alert property updated
    ///   - error:       Networking error (nil if no error)
    func setReceiverAlert(isOn: Bool, mount: Mount, linkId: String,
                          completion: @escaping (_ receiver: UploadLink?, _ error: Error?) -> Void ) {

        let method = Methods.LinkSetAlert
            .replacingOccurrences(of: "{mountId}", with: mount.id)
            .replacingOccurrences(of: "{linkId}", with: linkId)

        var headers = DefaultHeaders.PutHeaders
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token)"

        let json = ["alert": isOn]

        networkTask(requestType: .put, method: method, headers: headers, json: json, parameters: nil) { json, statusCode, error in

            guard error == nil else {
                completion(nil, error)
                return
            }

            guard statusCode == 200 else {
                completion(nil, ResponseError.other)
                return
            }

            guard let receiver = UploadLink(JSON: json) else {
                completion(nil, JSONError.parse("Could not parce the JSON for Receiver."))
                return
            }

            completion(receiver, nil)
        }
    }

    /// Set link validity
    ///
    /// - Parameters:
    ///   - mount:       Mount of link
    ///   - linkId:      Link id
    ///   - type:        Link type (.download or .upload)
    ///   - validTo:     timeIntervalSince1970 (seconds)
    ///   - completion:  Function to handle the status code and error response
    ///   - link:        Returned link with validity updated
    ///   - error:       Networking error (nil if no error)
    func setLinkCustomValidity(mount: Mount, linkId: String, type: LinkType, validTo: TimeInterval?,
                               completion: @escaping (_ link: Link?, _ error: Error?) -> Void ) {

        let method = Methods.LinkValidity
            .replacingOccurrences(of: "{mountId}", with: mount.id)
            .replacingOccurrences(of: "{linkType}", with: type.rawValue)
            .replacingOccurrences(of: "{linkId}", with: linkId)

        var headers = DefaultHeaders.PutHeaders
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token)"

        var json: [String: Any] = ["validFrom": NSNull(), "validTo": NSNull()]

        if let validTo = validTo {
            json["validTo"] = validTo * 1000
        }

        networkTask(requestType: .put, method: method, headers: headers, json: json, parameters: nil) { json, statusCode, error in

            guard error == nil else {
                completion(nil, error)
                return
            }

            guard statusCode == 200 else {
                completion(nil, ResponseError.other)
                return
            }

            switch type {
            case .download:
                guard let link = DownloadLink(JSON: json) else {
                    completion(nil, JSONError.parse("Could not parce the JSON for Link."))
                    return
                }
                completion(link, nil)

            case .upload:
                guard let receiver = UploadLink(JSON: json) else {
                    completion(nil, JSONError.parse("Could not parce the JSON for Receiver."))
                    return
                }
                completion(receiver, nil)
            }
        }
    }

    // MARK: - Bundle

    /// Gets the content of nodes of a location in the Cloud storage
    ///
    /// - Parameters:
    ///   - location: The location to get the content
    ///   - completion: The block called after the server has responded
    ///   - nodes: Returned content as an array of nodes
    ///   - error: The error occurred in the network request, nil for no error.
    func getBundle(for location: Location, completion: @escaping(_ nodes: [Node]?, _ rootNode: Node?, _ error: Error?) -> Void) {

        let method = Methods.Bundle.replacingOccurrences(of: "{id}", with: location.mount.id)
        var headers = DefaultHeaders.GetHeaders
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token)"

        let parameters = [ParametersKeys.Path: location.path]

        networkTask(requestType: .get, method: method, headers: headers, json: nil, parameters: parameters) { data, statusCode, error in

            guard error == nil else {
                completion(nil, nil, error)
                return
            }

            guard statusCode == 200 else {
                completion(nil, nil, ResponseError.other)
                return
            }

            guard let dict = data as? [String: Any],
                let nodesListJSON = dict["files"] as? [[String: Any]],
                let rootNodeJSON = dict["file"] else {
                    completion(nil, nil, JSONError.parse("Could not parse data for Bundle"))
                    return
            }

            let nodes = nodesListJSON.flatMap { Node(JSON: $0) }
            let rootNode = Node(JSON: rootNodeJSON)

            completion(nodes, rootNode, nil)
        }
    }

    // MARK: - Search

    /// Search for files or directories
    ///
    /// - Parameters:
    ///   - parameters: search parameters
    ///   - completion: The block called after the server has responded
    ///   - results: An array containing the search hits.
    ///   - error: The error occurred in the network request, nil for no error.
    func search(parameters: [String: String],
                completion: @escaping (_ nodeHits: [NodeHit]?, _ mountsDictionary: [String: Mount]?, _ error: Error?) -> Void) {

        let method = Methods.Search
        var headers = DefaultHeaders.GetHeaders
        headers[HeadersKeys.Authorization] = "Token \(DigiClient.shared.token)"

        networkTask(requestType: .get, method: method, headers: headers, json: nil, parameters: parameters) { json, statusCode, error in

            guard error == nil else {
                completion(nil, nil, error)
                return
            }

            guard statusCode == 200 else {
                completion(nil, nil, ResponseError.other)
                return
            }

            guard let json = json as? [String: Any],
                let hitsJSON = json["hits"] as? [[String: Any]],
                let mountsJSON = json["mounts"] as? [String: Any] else {
                    completion(nil, nil, JSONError.parse("Couldn't parse the json to get the hits and mounts from search results."))
                    return
            }

            let nodeHits = hitsJSON.flatMap { NodeHit(JSON: $0) }

            var mountsDictionary: [String: Mount] = [:]

            for (mountId, mountAny) in mountsJSON {
                if let mount = Mount(JSON: mountAny) {
                    mountsDictionary[mountId] = mount
                } else {
                    completion(nil, nil, JSONError.parse("Couldn't extract mount from results."))
                    return
                }
            }
            completion(nodeHits, mountsDictionary, nil)
        }
    }
}
