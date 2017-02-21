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
}

extension Location {
    var parentPath: String {
        return (path as NSString).deletingLastPathComponent
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
