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
    let path:  String

    // MARK: - Initializers and Deinitializers

    init(mount: Mount, path: String) {
        self.mount = mount
        self.path = path
    }
}
