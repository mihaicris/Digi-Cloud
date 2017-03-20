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
    let root: [String: String]?
    let online: Bool
    let owner: User
    var users: [User]
    let isShared: Bool
    let permissions: Permissions
    let spaceTotal: Int?
    let spaceUsed: Int?
    let isPrimary: Bool
    let canWrite: Bool
    let canUpload: Bool
    let overQuota: Bool
    let almostOverQuota: Bool
    let userAdded: TimeInterval
}

extension Mount {
    init?(JSON: Any?) {
        if JSON == nil { return nil }

        guard let JSON = JSON as? [String: Any],
            let id = JSON["id"] as? String,
            let name = JSON["name"] as? String,
            let type = JSON["type"] as? String,
            let origin = JSON["origin"] as? String,
            let online = JSON["online"] as? Bool,
            let usersJSON = JSON["users"] as? [Any],
            let isShared = JSON["isShared"] as? Bool,
            let isPrimary = JSON["isPrimary"] as? Bool,
            let canWrite = JSON["canWrite"] as? Bool,
            let canUpload = JSON["canUpload"] as? Bool,
            let overQuota = JSON["overQuota"] as? Bool,
            let almostOverQuota = JSON["almostOverQuota"] as? Bool,
            let userAdded = JSON["userAdded"] as? TimeInterval
            else {
                print("Couldnt parse Mount JSON")
                return nil
        }

        if let owner = User(JSON: JSON["owner"]),
            let permissions = Permissions(JSON: JSON["permissions"]) {
            self.owner = owner
            self.permissions = permissions
        } else {
            return nil
        }

        self.id = id
        self.name = name
        self.type = type
        self.origin = origin
        self.root = JSON["root"] as? [String: String]
        self.online = online
        self.users = usersJSON.flatMap { User(JSON: $0) }
        self.isShared = isShared
        self.spaceTotal = JSON["spaceTotal"] as? Int
        self.spaceUsed = JSON["spaceUsed"] as? Int
        self.isPrimary = isPrimary
        self.canWrite = canWrite
        self.canUpload = canUpload
        self.overQuota = overQuota
        self.almostOverQuota = almostOverQuota
        self.userAdded = userAdded
    }

    static func == (lhs: Mount, rhs: Mount) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }
}
