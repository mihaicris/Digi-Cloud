//
//  File.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 19/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import Foundation

struct File {
    var name: String
    let type: String
    let modified: TimeInterval
    let size: Int64
    let contentType: String

    init(name: String, type: String, modified: TimeInterval, size: Int64, contentType: String) {
        self.name = name
        self.type = type
        self.modified = modified
        self.size = size
        self.contentType = contentType
    }
}

extension File: JSONDecodable {
    init?(JSON: Any) {

        guard let JSON = JSON as? [String: Any],
            let name = JSON["name"] as? String,
            let type = JSON["type"] as? String,
            let modified = JSON["modified"] as? TimeInterval,
            let size = JSON["size"] as? Int64,
            let contentType = JSON["contentType"] as? String
            else {
                print("Could not parce keys")
                return nil
        }
        self.name = name
        self.type = type
        self.modified = modified
        self.size = size
        self.contentType = contentType
    }
}
