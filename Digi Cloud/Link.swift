//
//  Link.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 13/02/2017.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import Foundation

enum LinkType: String {
    case download = "links"
    case upload = "receivers"
}

struct Link {

    // MARK: - Properties

    let id: String
    let name: String
    let path: String
    let counter: Int
    let url: String
    let shortUrl: String
    let hash: String
    let host: String
    let hasPassword: Bool
    let password: String?
    let validFrom: TimeInterval?
    let validTo: TimeInterval?
    let passwordRequired: Bool
}

extension Link {
    init?(JSON: Any?) {
        if JSON == nil { return nil }
        guard let JSON = JSON as? [String: Any],
            let id = JSON["id"] as? String,
            let name = JSON["name"] as? String,
            let path = JSON["path"] as? String,
            let counter = JSON["counter"] as? Int,
            let url = JSON["url"] as? String,
            let shortUrl = JSON["shortUrl"] as? String,
            let hash = JSON["hash"] as? String,
            let host = JSON["host"] as? String,
            let hasPassword = JSON["hasPassword"] as? Bool,
            let passwordRequired = JSON["passwordRequired"] as? Bool
            else {
                print("Couldnt parse JSON")
                return nil
        }

        self.id = id
        self.name = name
        self.path = path
        self.counter = counter
        self.url =  url
        self.shortUrl = shortUrl
        self.hash = hash
        self.host = host
        self.hasPassword = hasPassword
        self.password = JSON["password"] as? String
        self.passwordRequired =  passwordRequired
        self.validFrom = JSON["validFrom"] as? TimeInterval
        self.validTo = JSON["validTo"] as? TimeInterval
    }
}
