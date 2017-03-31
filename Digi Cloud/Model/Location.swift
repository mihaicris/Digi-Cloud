//
//  Location.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 22/11/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import Foundation

struct Location {

    // MARK: - Properties

    var mount: Mount
    let path: String
}

extension Location {
    var parentLocation: Location {

        var parentPath = (path as NSString).deletingLastPathComponent

        if parentPath != "/" {
            parentPath += "/"
        }

        return Location(mount: self.mount, path: parentPath)
    }

    func appendingPathComponentFrom(node: Node) -> Location {
        let newPath = path + node.name + (node.type == "dir" ? "/" : "")
        return Location(mount: mount, path: newPath)
    }

    func appendingPathComponent(_ name: String, isFolder: Bool) -> Location {
        let newPath = path + name + (isFolder ? "/" : "")
        return Location(mount: mount, path: newPath)
    }
}

extension Location: Equatable {
    static func == (lhs: Location, rhs: Location) -> Bool {
        return lhs.mount == rhs.mount && lhs.path == rhs.path
    }
}

extension Location: Hashable {
    var hashValue: Int {
        return mount.name.hashValue ^ (path.hashValue &* 72913)
    }
}
