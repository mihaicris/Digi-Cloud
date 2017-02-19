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
    init?(JSON: Any?) {
        if JSON == nil { return nil }
        guard let JSON = JSON as? [String: Any],
            let name = JSON["name"] as? String,
            let id = JSON["id"] as? String
            else {
                print("Couldnt parse JSON")
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
