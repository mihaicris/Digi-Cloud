//
//  Constants.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 16/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import Foundation

struct API {
    static let Scheme = "https"
    static let Host = "storage.rcs-rds.ro"
    
    struct Paths {
        static let Token	= "/token"
        static let User = "/api/v2/user"
        static let Password = "/api/v2/user/password"
        static let Bookmarks = "/api/v2/user/bookmarks"
        static let Mounts = "/api/v2/mounts"
    }
}

struct Segues {
    static let toFiles = "toFiles"
}
