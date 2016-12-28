//
//  Node.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 19/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import Foundation

struct Node {

    // MARK: - Properties

    let name: String
    let type: String
    let modified: TimeInterval
    let size: Int64
    let contentType: String
    let hash: String
    let ext: String
    var location: Location
    var score: Double

    // MARK: - Initializers and Deinitializers

    init(name: String, type: String, modified: TimeInterval, size: Int64, contentType: String, hash: String,
         score: Double = 0, location: Location) {
        self.name = name
        self.type = type
        self.modified = modified
        self.size = size
        self.contentType = contentType
        self.hash = hash
        self.score = score
        self.location = location
        let components = self.name.components(separatedBy: ".")
        self.ext = components.count > 1 ? components.last! : ""
    }
}

extension Node {
    init?(JSON: Any, location: Location) {
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
        self.hash = JSON["hash"] is NSNull ? "" : JSON["hash"] as? String ?? ""
        self.score = JSON["score"] as? Double ?? 0
        self.location = location
        let components = self.name.components(separatedBy: ".")
        self.ext = components.count > 1 ? components.last! : ""
    }
}

extension Node: Hashable {
    var hashValue: Int {
        get {
            return location.hashValue ^ (name.hashValue &* 72913)
        }
    }
}

extension Node: Equatable {
    static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.location == rhs.location

    }
}
