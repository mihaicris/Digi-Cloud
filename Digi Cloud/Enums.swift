//
//  Enums.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 03/03/2017.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

// ---------Errors ----------------

enum NetworkingError: Error {
    case requestTimedOut(String)
    case requestWasCancelled(String)
    case internetOffline(String)
    case get(String)
    case del(String)
    case wrongStatus(String)
    case data(String)

}

enum ResponseError: Error {
    case notFound
    case other
}

enum JSONError: Error {
    case parse(String)
}

enum AuthenticationError: Error {
    case login
    case revoke
}

enum ConversionError: Error {
    case data(String)
}

// ---------------------------------

enum RequestType: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum LinkType: String {
    case download = "links"
    case upload = "receivers"
}

enum ActionType: Int {
    case bookmark
    case copy
    case createDirectory
    case delete
    case directoryInfo
    case makeOffline
    case move
    case noAction
    case rename
    case selectionMode
    case sendDownloadLink
    case sendUploadLink
    case makeShare
    case shareInfo
    case manageShare
    case showSearchResult
}

enum SortMethodType: Int {
    case byName = 1
    case byDate
    case bySize
    case byContentType
}

enum CacheType {
    case file
    case profile
}

enum WaitingType {
    case started
    case stopped
    case hidden
}

enum MountUserUpdateOperation {
    case add
    case updatePermissions
    case remove
}
