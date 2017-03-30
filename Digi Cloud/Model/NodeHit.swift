//
//  NodeSearchResult.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 19/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import Foundation

struct NodeHit {

    // MARK: - Properties

    let mountId: String
    let path: String
    let score: Double
    let name: String
    let type: String
    let modified: TimeInterval
    let size: Int64
    let contentType: String
}

extension NodeHit {
    init?(JSON: Any) {
        guard let JSON = JSON as? [String: Any],
            let mountId = JSON["mountId"] as? String,
            let path = JSON["path"] as? String,
            let score = JSON["score"] as? Double,
            let name = JSON["name"] as? String,
            let type = JSON["type"] as? String,
            let modified = JSON["modified"] as? TimeInterval,
            let size = JSON["size"] as? Int64,
            let contentType = JSON["contentType"] as? String
            else {
                print("Could not parse NodeHit JSON.")
            return nil
        }
        self.mountId = mountId
        self.path = path
        self.score = score
        self.name = name
        self.type = type
        self.modified = modified
        self.size = size
        self.contentType = contentType
    }
}

extension NodeHit {
    var ext: String {
        return (name as NSString).pathExtension
    }
}
