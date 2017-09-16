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
    init?(object: Any) {
        guard
            let jsonDictionary = object as? [String: Any],
            let mountId = jsonDictionary["mountId"] as? String,
            let path = jsonDictionary["path"] as? String,
            let score = jsonDictionary["score"] as? Double,
            let name = jsonDictionary["name"] as? String,
            let type = jsonDictionary["type"] as? String,
            let modified = jsonDictionary["modified"] as? TimeInterval,
            let size = jsonDictionary["size"] as? Int64,
            let contentType = jsonDictionary["contentType"] as? String
            else { return nil }
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
