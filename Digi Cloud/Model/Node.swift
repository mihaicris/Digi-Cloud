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
    var mount: Mount?
    let mountPath: String?
    var link: DownloadLink?
    var receiver: UploadLink?
    var bookmark: Bookmark?
}

extension Node {
    init?(object: Any?) {
        guard
            let jsonDictionary = object as? [String: Any],
            let name = jsonDictionary["name"] as? String,
            let type = jsonDictionary["type"] as? String,
            let modified = jsonDictionary["modified"] as? TimeInterval,
            let size = jsonDictionary["size"] as? Int64,
            let contentType = jsonDictionary["contentType"] as? String
            else { return nil }
        self.name = name
        self.type = type
        self.modified = modified
        self.size = size
        self.contentType = contentType
        self.hash = jsonDictionary["hash"] as? String
        self.mount = Mount(object: jsonDictionary["mount"])
        self.mountPath = jsonDictionary["mountPath"] as? String
        self.link = DownloadLink(object: jsonDictionary["link"])
        self.receiver = UploadLink(object: jsonDictionary["receiver"])
        self.bookmark = Bookmark(object: jsonDictionary["bookmark"])
    }
}

extension Node {

    // Extension of the node name (otherwise "")
    var ext: String {
        return (name as NSString).pathExtension
    }

    // Location in given Mount
    func location(in parentLocation: Location) -> Location {

        var path = parentLocation.path + name

        if type == "dir" {
            path += "/"
        }

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
        return lhs.name == rhs.name
    }
}
