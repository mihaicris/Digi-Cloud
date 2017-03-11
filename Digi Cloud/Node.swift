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

    // via API
    var name: String
    let type: String
    let modified: TimeInterval
    let size: Int64
    let contentType: String
    let hash: String?
    var share: Mount?
    var downloadLink: DownloadLink?
    var uploadLink: UploadLink?
    var bookmark: Bookmark?
}

extension Node {
    init?(JSON: Any, mountId: String? = nil) {
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

        if let mountId = mountId {
            self.bookmark = Bookmark(JSON: JSON["bookmark"], mountId: mountId)
        }
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
