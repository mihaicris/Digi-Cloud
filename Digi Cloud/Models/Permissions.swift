//
//  Permission.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 04/03/2017.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

struct Permissions {

    // MARK: - Properties
    let read: Bool
    let owner: Bool
    var mount: Bool
    var createReceiver: Bool
    var comment: Bool
    var write: Bool
    var createLink: Bool
}

extension Permissions {

    init(mount: Bool = false, write: Bool = false, comment: Bool = false,
         createLink: Bool = false, createReceiver: Bool = false) {
        self.read = true
        self.owner = false
        self.mount = mount
        self.createReceiver = createReceiver
        self.comment = comment
        self.write = write
        self.createLink = createLink
    }

    init?(object: Any?) {
        guard
            let jsonDictionary = object as? [String: Any],
            let read = jsonDictionary["READ"] as? Bool,
            let owner = jsonDictionary["OWNER"] as? Bool,
            let mount = jsonDictionary["MOUNT"] as? Bool,
            let createReceiver = jsonDictionary["CREATE_RECEIVER"] as? Bool,
            let comment = jsonDictionary["COMMENT"] as? Bool,
            let write = jsonDictionary["WRITE"] as? Bool,
            let createLink = jsonDictionary["CREATE_LINK"] as? Bool
            else { return nil }
        self.read = read
        self.owner = owner
        self.mount = mount
        self.createReceiver = createReceiver
        self.comment = comment
        self.write = write
        self.createLink = createLink
    }

    var json: [String: Bool] {
        return [
            "OWNER": self.owner,
            "READ": self.read,
            "WRITE": self.write,
            "MOUNT": self.mount,
            "CREATE_LINK": self.createLink,
            "CREATE_RECEIVER": self.createReceiver,
            "COMMENT": self.comment
        ]
    }

    var isExtended: Bool {
        return mount || createReceiver || comment || write || createLink
    }

}
