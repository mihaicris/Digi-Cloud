//
//  Enums.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 03/03/2017.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

enum RequestType: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

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

enum LinkType: String {
    case download = "links"
    case upload = "receivers"
}

enum ActionType: Int {
    case bookmark
    case copy
    case createDirectory
    case delete
    case folderInfo
    case makeOffline
    case move
    case noAction
    case rename
    case selectionMode
    case sendDownloadLink
    case sendUploadLink
    case share
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

enum UserOperation {
    case add
    case updatePermissions
    case remove
}
