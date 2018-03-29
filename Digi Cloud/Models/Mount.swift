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

    let identifier: String
    let name: String
    let type: String
    let origin: String
    let root: RootMount?
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
    init?(object: Any?) {
        guard
            let jsonDictionary = object as? [String: Any],
            let identifier = jsonDictionary["id"] as? String,
            let name = jsonDictionary["name"] as? String,
            let type = jsonDictionary["type"] as? String,
            let origin = jsonDictionary["origin"] as? String,
            let online = jsonDictionary["online"] as? Bool,
            let usersJSON = jsonDictionary["users"] as? [Any],
            let isShared = jsonDictionary["isShared"] as? Bool,
            let isPrimary = jsonDictionary["isPrimary"] as? Bool,
            let canWrite = jsonDictionary["canWrite"] as? Bool,
            let canUpload = jsonDictionary["canUpload"] as? Bool,
            let overQuota = jsonDictionary["overQuota"] as? Bool,
            let almostOverQuota = jsonDictionary["almostOverQuota"] as? Bool,
            let userAdded = jsonDictionary["userAdded"] as? TimeInterval
            else { return nil }

        if let owner = User(object: jsonDictionary["owner"]),
            let permissions = Permissions(object: jsonDictionary["permissions"]) {
            self.owner = owner
            self.permissions = permissions
        } else {
            return nil
        }

        self.identifier = identifier
        self.name = name
        self.type = type
        self.origin = origin
        self.root = RootMount(object: jsonDictionary["root"])
        self.online = online
        self.users = usersJSON.compactMap { User(object: $0) }
        self.isShared = isShared
        self.spaceTotal = jsonDictionary["spaceTotal"] as? Int
        self.spaceUsed = jsonDictionary["spaceUsed"] as? Int
        self.isPrimary = isPrimary
        self.canWrite = canWrite
        self.canUpload = canUpload
        self.overQuota = overQuota
        self.almostOverQuota = almostOverQuota
        self.userAdded = userAdded
    }

    static func == (lhs: Mount, rhs: Mount) -> Bool {
        return lhs.identifier == rhs.identifier && lhs.name == rhs.name
    }
}
