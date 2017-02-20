//
//  DigiConstants.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 16/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import Foundation

struct API {
    static let Scheme           = "https"
    static let Host             = "storage.rcs-rds.ro"
}

struct DefaultHeaders {
    static let GetHeaders       = ["Accept": "application/json"]
    static let DelHeaders       = ["Accept": "application/json"]
    static let PostHeaders      = ["Accept": "application/json", "Content-Type": "application/json"]
    static let PutHeaders       = ["Accept": "application/json", "Content-Type": "application/json"]
}

struct HeadersKeys {
    static let Accept           = "Accept"
    static let Email            = "X-Koofr-Email"
    static let Password         = "X-Koofr-Password"
    static let Authorization    = "Authorization"
}

struct HeaderResponses {
    static let Token            = "X-koofr-token"
}

struct ParametersKeys {
    static let Path             = "path"
    static let MountID          = "mountId"
    static let QueryString      = "query"
}

struct DataJSONKeys {
    static let folderName       = "name"
}

struct Methods {
    static let Token            = "/token"
    static let User             = "/api/v2/user"
    static let UserPassword     = "/api/v2/user/password"
    static let UserBookmarks    = "/api/v2/user/bookmarks"
    static let Mounts           = "/api/v2/mounts"
    static let Bundle           = "/api/v2/mounts/{id}/bundle"
    static let FilesList        = "/api/v2/mounts/{id}/files/list"
    static let FilesGet         = "/api/v2/mounts/{id}/files/get"
    static let FilesRename      = "/api/v2/mounts/{id}/files/rename"
    static let FilesRemove      = "/api/v2/mounts/{id}/files/remove"
    static let FilesFolder      = "/api/v2/mounts/{id}/files/folder"
    static let FilesTree        = "/api/v2/mounts/{id}/files/tree"
    static let FilesCopy        = "/api/v2/mounts/{id}/files/copy"
    static let FilesMove        = "/api/v2/mounts/{id}/files/move"
    static let Links            = "/api/v2/mounts/{id}/links"
    static let Receivers        = "/api/v2/mounts/{id}/receivers"
    static let Search           = "/api/v2/search"
}

struct CacheFolders {
    static let Profiles  = "ProfileImages"
    static let Files    = "Files"
}
