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

    let identifier: String
    let name: String
    let path: String
}

extension RootMount {
    init?(object: Any?) {
        guard
            let jsonDictionary = object as? [String: Any],
            let identifier = jsonDictionary["id"] as? String,
            let name = jsonDictionary["name"] as? String,
            let path = jsonDictionary["path"] as? String
            else { return nil }
        self.identifier = identifier
        self.name = name
        self.path = path
    }
}
