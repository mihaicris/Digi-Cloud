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
    var mountId: String
    let path: String
}

extension Bookmark {
    init?(object: Any?) {
        guard
            let jsonDictionary = object as? [String: Any],
            let name = jsonDictionary["name"] as? String,
            let path = jsonDictionary["path"] as? String
            else { return nil }
        self.name = name
        self.mountId = jsonDictionary["mountId"] as? String ?? ""
        self.path = path + "/"
    }
}

extension Bookmark: Equatable {
    static func == (lhs: Bookmark, rhs: Bookmark) -> Bool {
        return lhs.mountId == rhs.mountId && lhs.path == rhs.path
    }
}
