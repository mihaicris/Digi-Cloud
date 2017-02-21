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

    var name: String
    let type: String
    let modified: TimeInterval
    let size: Int64
    let contentType: String
    let hash: String?
    let share: Mount?
    let link: Link?
    let receiver: Receiver?
    var parentLocation: Location
}

extension Node {
    init?(JSON: Any, parentLocation: Location) {
        guard let JSON = JSON as? [String: Any],
            let name = JSON["name"] as? String,
            let type = JSON["type"] as? String,
            let modified = JSON["modified"] as? TimeInterval,
            let size = JSON["size"] as? Int64,
            let contentType = JSON["contentType"] as? String
            else {
                print("Couldnt parse JSON")
                return nil
        }

        self.name = name
        self.type = type
        self.modified = modified
        self.size = size
        self.contentType = contentType
        self.hash = JSON["hash"] as? String
        self.share = Mount(JSON: JSON["mount"])
        self.link = Link(JSON: JSON["link"])
        self.receiver = Receiver(JSON: JSON["receiver"])
        self.parentLocation = parentLocation
    }
}

extension Node {
    var ext: String {
        return (name as NSString).pathExtension
    }

    var location: Location {
        let path = parentLocation.path + name + (type == "dir" ? "/" : "")
        return Location(mount: parentLocation.mount, path: path )
    }
}

extension Node: Hashable {
    var hashValue: Int {
        return self.hash?.hashValue ?? 0
    }
}

extension Node: Equatable {
    static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.location == rhs.location
    }
}
