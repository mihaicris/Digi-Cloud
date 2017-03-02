//
//  Bookmark.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 16/02/2017.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import Foundation

struct Bookmark {

    // MARK: - Properties

    let name: String
    let mountId: String
    let path: String
}

extension Bookmark {
    init?(JSON: Any?) {
        if JSON == nil { return nil }
        guard let JSON = JSON as? [String: Any],
            let name = JSON["name"] as? String,
            let mountId = JSON["mountId"] as? String,
            let path = JSON["path"] as? String
            else {
                print("Couldnt parse JSON")
                return nil
        }

        self.name = name
        self.mountId = mountId
        self.path = path
    }
}

extension Bookmark: Equatable {
    static func ==(lhs: Bookmark, rhs: Bookmark) -> Bool {
        return lhs.mountId == rhs.mountId && lhs.path == rhs.path
    }
}
