//
//  Mount.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 19/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import Foundation

struct Mount {

    // MARK: - Properties

    let id: String
    let name: String
}

extension Mount {
    init?(JSON: Any) {
        guard let JSON = JSON as? [String: Any],
            let name = JSON["name"] as? String,
            let id = JSON["id"] as? String
            else {
            print("Could not parse keys")
            return nil
        }
        self.name = name
        self.id = id
    }
}

extension Mount: Equatable {
    static func == (lhs: Mount, rhs: Mount) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }
}
