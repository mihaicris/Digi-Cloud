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
    static let Headers          = ["Content-Type": "application/json",
                                   "Accept"      : "application/json"]
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
    static let Password         = "/api/v2/user/password"
    static let Bookmarks        = "/api/v2/user/bookmarks"
    static let Mounts           = "/api/v2/mounts"
    static let ListFiles        = "/api/v2/mounts/{id}/files/list"
    static let GetFile          = "/api/v2/mounts/{id}/files/get"
    static let Rename           = "/api/v2/mounts/{id}/files/rename"
    static let Remove           = "/api/v2/mounts/{id}/files/remove"
    static let CreateFolder     = "/api/v2/mounts/{id}/files/folder"
    static let Tree             = "/api/v2/mounts/{id}/files/tree"
    static let Copy             = "/api/v2/mounts/{id}/files/copy"
    static let Move             = "/api/v2/mounts/{id}/files/move"
    static let Search           = "/api/v2/search"
}
