//
//  RootMount.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 20/03/2017.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import Foundation

struct RootMount {

    // MARK: - Properties

    let id: String
    let name: String
    let path: String
}

extension RootMount {
    init?(JSON: Any?) {
        if JSON == nil { return nil }

        guard let JSON = JSON as? [String: Any],
            let id = JSON["id"] as? String,
            let name = JSON["name"] as? String,
            let path = JSON["path"] as? String else {
                print("Couldnt parse Mount JSON")
                return nil
        }

        self.id = id
        self.name = name
        self.path = path
    }
}
