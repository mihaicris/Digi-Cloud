//
//  File.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 19/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import Foundation


class File {
    let name: String
    let type: String
    let modified: TimeInterval
    let size: Double
    let contentType: String
    let hash: String

    init(name: String, type: String, modified: TimeInterval, size: Double, contentType: String, hash: String) {
        self.name = name
        self.type = type
        self.modified = modified
        self.size = size
        self.contentType = contentType
        self.hash = hash
    }
}
