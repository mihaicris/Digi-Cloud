//
//  DownloadLink.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 13/02/2017.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import Foundation

struct DownloadLink: Link {

    // MARK: - Properties

    let identifier: String
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

    // own property
    let passwordRequired: Bool
}

extension DownloadLink {
    init?(object: Any?) {
        guard
            let jsonDictionary = object as? [String: Any],
            let identifier = jsonDictionary["id"] as? String,
            let name = jsonDictionary["name"] as? String,
            let path = jsonDictionary["path"] as? String,
            let counter = jsonDictionary["counter"] as? Int,
            let url = jsonDictionary["url"] as? String,
            let shortUrl = jsonDictionary["shortUrl"] as? String,
            let hash = jsonDictionary["hash"] as? String,
            let host = jsonDictionary["host"] as? String,
            let hasPassword = jsonDictionary["hasPassword"] as? Bool,
            let passwordRequired = jsonDictionary["passwordRequired"] as? Bool
            else { return nil }
        self.identifier = identifier
        self.name = name
        self.path = path
        self.counter = counter
        self.url =  url
        self.shortUrl = shortUrl
        self.hash = hash
        self.host = host
        self.hasPassword = hasPassword
        self.password = jsonDictionary["password"] as? String
        self.passwordRequired =  passwordRequired
        self.validFrom = jsonDictionary["validFrom"] as? TimeInterval
        self.validTo = jsonDictionary["validTo"] as? TimeInterval
    }
}
