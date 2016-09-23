//
//  File.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 19/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import Foundation

struct File {
    let name: String
    let type: String
    let modified: TimeInterval
    let size: Double
    let contentType: String
    
    init(name: String, type: String, modified: TimeInterval, size: Double, contentType: String) {
        self.name = name
        self.type = type
        self.modified = modified
        self.size = size
        self.contentType = contentType
    }
}

extension File: JSONDecodable {
    init?(JSON: Any) {
        
        guard let JSON = JSON as? [String: Any] else { return nil }
        
        guard let name = JSON["name"] as? String,
            let type = JSON["type"] as? String,
            let modified = JSON["modified"] as? TimeInterval,
            let size = JSON["size"] as? Double,
            let contentType = JSON["contentType"] as? String
            else {
                print("Could not parce keys")
                return nil
        }
        
        self.name = name
        self.type = type
        self.modified = modified
        self.size = size
        self.contentType = contentType
        
    }
}
