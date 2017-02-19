//
//  Receiver.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 15/02/2017.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import Foundation

struct Receiver {

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
    let alert: Bool
}

extension Receiver {
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
            let alert = JSON["alert"] as? Bool
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
        self.validFrom = JSON["validFrom"] as? TimeInterval
        self.validTo = JSON["validTo"] as? TimeInterval
        self.alert =  alert
    }
}
