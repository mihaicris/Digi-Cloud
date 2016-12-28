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

    let mount: Mount
    let path: String
    var nodeName: String? {
        return path.components(separatedBy: "/").last
    }

    // MARK: - Initializers and Deinitializers

    init(mount: Mount, path: String) {
        self.mount = mount
        self.path = path
    }
}

extension Location: Equatable {
    static func == (lhs: Location, rhs: Location) -> Bool {
        return lhs.mount == rhs.mount && lhs.path == rhs.path
    }
}

extension Location: Hashable {
    var hashValue: Int {
        get {
            return mount.name.hashValue ^ (path.hashValue &* 72913)
        }
    }
}
