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
    var create_receiver: Bool
    var comment: Bool
    var write: Bool
    var create_link: Bool
}

extension Permissions {

    init(mount: Bool = false, write: Bool = false, comment: Bool = false,
         create_link: Bool = false, create_receiver: Bool = false) {
        self.read = true
        self.owner = false
        self.mount = mount
        self.create_receiver = create_receiver
        self.comment = comment
        self.write = write
        self.create_link = create_link
    }

    init?(object: Any?) {
        guard
            let jsonDictionary = object as? [String: Any],
            let read = jsonDictionary["READ"] as? Bool,
            let owner = jsonDictionary["OWNER"] as? Bool,
            let mount = jsonDictionary["MOUNT"] as? Bool,
            let create_receiver = jsonDictionary["CREATE_RECEIVER"] as? Bool,
            let comment = jsonDictionary["COMMENT"] as? Bool,
            let write = jsonDictionary["WRITE"] as? Bool,
            let create_link = jsonDictionary["CREATE_LINK"] as? Bool
            else { return nil }
        self.read = read
        self.owner = owner
        self.mount = mount
        self.create_receiver = create_receiver
        self.comment = comment
        self.write = write
        self.create_link = create_link
    }

    var json: [String: Bool] {
        return [
            "OWNER": self.owner,
            "READ": self.read,
            "WRITE": self.write,
            "MOUNT": self.mount,
            "CREATE_LINK": self.create_link,
            "CREATE_RECEIVER": self.create_receiver,
            "COMMENT": self.comment
        ]
    }

    var isExtended: Bool {
        return mount || create_receiver || comment || write || create_link
    }

}
