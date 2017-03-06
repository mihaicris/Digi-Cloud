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
    let type: String
    let origin: String
    let owner: User
    let users: [User]
    let isShared: Bool
    let spaceTotal: Int
    let spaceUsed: Int
    let canWrite: Bool
    let canUpload: Bool
    let overQuota: Bool
    let almostOverQuota: Bool
}

extension Mount {
    init?(JSON: Any?) {
        if JSON == nil { return nil }
        guard let JSON = JSON as? [String: Any],
            let id = JSON["id"] as? String,
            let name = JSON["name"] as? String,
            let type = JSON["type"] as? String,
            let origin = JSON["origin"] as? String,
            let owner = User(JSON: JSON["owner"] as? [String: Any]),
            let usersJSON = JSON["users"] as? [Any],
            let isShared = JSON["isShared"] as? Bool,
            let spaceTotal = JSON["spaceTotal"] as? Int,
            let spaceUsed = JSON["spaceUsed"] as? Int,
            let canWrite = JSON["canWrite"] as? Bool,
            let canUpload = JSON["canUpload"] as? Bool,
            let overQuota = JSON["overQuota"] as? Bool,
            let almostOverQuota = JSON["almostOverQuota"] as? Bool
            else {
                print("Couldnt parse Mount JSON")
                return nil
        }
        
        self.id = id
        self.name = name
        self.type = type
        self.origin = origin
        self.owner = owner
        self.users = usersJSON.flatMap { User(JSON: $0) }
        self.isShared = isShared
        self.spaceTotal = spaceTotal
        self.spaceUsed = spaceUsed
        self.canWrite = canWrite
        self.canUpload = canUpload
        self.overQuota = overQuota
        self.almostOverQuota = almostOverQuota
    }

    static func == (lhs: Mount, rhs: Mount) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }
}
