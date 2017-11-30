//
//  UploadLink.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 15/02/2017.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import Foundation

struct UploadLink: Link {

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

    // own property
    let alert: Bool
}

extension UploadLink {
    init?(object: Any?) {
        guard
            let jsonDictionary = object as? [String: Any],
            let id = jsonDictionary["id"] as? String,
            let name = jsonDictionary["name"] as? String,
            let path = jsonDictionary["path"] as? String,
            let counter = jsonDictionary["counter"] as? Int,
            let url = jsonDictionary["url"] as? String,
            let shortUrl = jsonDictionary["shortUrl"] as? String,
            let hash = jsonDictionary["hash"] as? String,
            let host = jsonDictionary["host"] as? String,
            let hasPassword = jsonDictionary["hasPassword"] as? Bool,
            let alert = jsonDictionary["alert"] as? Bool
            else { return nil }
        self.id = id
        self.name = name
        self.path = path
        self.counter = counter
        self.url =  url
        self.shortUrl = shortUrl
        self.hash = hash
        self.host = host
        self.hasPassword = hasPassword
        self.password = jsonDictionary["password"] as? String
        self.validFrom = jsonDictionary["validFrom"] as? TimeInterval
        self.validTo = jsonDictionary["validTo"] as? TimeInterval
        self.alert =  alert
    }
}
