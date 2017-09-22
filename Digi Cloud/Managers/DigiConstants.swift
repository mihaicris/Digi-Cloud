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
    static let Limit            = "limit"
}

struct DataJSONKeys {
    static let folderName    = "name"
}

struct Methods {
    static let Token               = "/token"
    static let User                = "/api/v2/user"
    static let UserProfileImage    = "/content/api/v2/users/{userId}/profile-picture"
    static let UserProfileImageSet = "/content/api/v2/user/profile-picture/update"
    static let UserPassword        = "/api/v2/user/password"
    static let UserSettingsSec     = "/api/v2/user/settings/security"
    static let UserBookmarks       = "/api/v2/user/bookmarks"
    static let Mounts              = "/api/v2/mounts"
    static let MountEdit           = "/api/v2/mounts/{id}"
    static let MountCreate         = "/api/v2/mounts/{id}/submounts"
    static let Bundle              = "/api/v2/mounts/{id}/bundle"
    static let UserAdd             = "/api/v2/mounts/{id}/users"
    static let UserChange          = "/api/v2/mounts/{mountId}/users/{userId}"
    static let FilesInfo           = "/api/v2/mounts/{mountId}/files/info"
    static let FilesList           = "/api/v2/mounts/{id}/files/list"
    static let FilesGet            = "/api/v2/mounts/{id}/files/get"
    static let FilesRename         = "/api/v2/mounts/{id}/files/rename"
    static let FilesRemove         = "/api/v2/mounts/{id}/files/remove"
    static let FilesFolder         = "/api/v2/mounts/{id}/files/folder"
    static let FilesTree           = "/api/v2/mounts/{id}/files/tree"
    static let FilesCopy           =  "/api/v2/mounts/{id}/files/copy"
    static let FilesMove           = "/api/v2/mounts/{id}/files/move"
    static let Links               = "/api/v2/mounts/{mountId}/{linkType}"
    static let LinkDelete          = "/api/v2/mounts/{mountId}/{linkType}/{linkId}"
    static let LinkRemovePassword  = "/api/v2/mounts/{mountId}/{linkType}/{linkId}/password"
    static let LinkResetPassword   = "/api/v2/mounts/{mountId}/{linkType}/{linkId}/password/reset"
    static let LinkCustomURL       = "/api/v2/mounts/{mountId}/{linkType}/{linkId}/urlHash"
    static let LinkValidity        = "/api/v2/mounts/{mountId}/{linkType}/{linkId}/validity"
    static let LinkSetAlert        = "/api/v2/mounts/{mountId}/receivers/{linkId}/alert"
    static let Search              = "/api/v2/search"
}

struct CacheFolders {
    static let Profiles  = "ProfileImages"
    static let Files     = "Files"
}
