//
//  Node.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 19/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import Foundation

struct Node: ContentItem {

    // MARK: - Properties

    // via API
    var name: String
    let type: String
    let modified: TimeInterval
    let size: Int64
    let contentType: String
    let hash: String?
    let share: Mount?
    var downloadLink: DownloadLink?
    var uploadLink: UploadLink?
    var bookmark: Bookmark?

    //  via Constructor
    let parentLocation: Location
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
        self.downloadLink = DownloadLink(JSON: JSON["link"])
        self.uploadLink = UploadLink(JSON: JSON["receiver"])
        self.parentLocation = parentLocation

        self.bookmark = Bookmark(JSON: JSON["bookmark"], mountId: parentLocation.mount.id)

    }
}

extension Node {

    // Extension of the node name (otherwise "")
    var ext: String {
        return (name as NSString).pathExtension
    }

    // Location of the Node
    var location: Location {

        let path: String

        if name == "" {
            path = "/"
        } else {
            path = parentLocation.path + name + (type == "dir" ? "/" : "")
        }
        return Location(mount: parentLocation.mount, path: path )
    }

    mutating func updateNode(with link: Link?) {
        if let link = link as? DownloadLink {
            self.downloadLink = link
        } else if let link = link as? UploadLink {
            self.uploadLink = link
        }
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
