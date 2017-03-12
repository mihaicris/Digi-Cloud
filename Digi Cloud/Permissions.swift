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

    init?(JSON: Any?) {
        if JSON == nil { return nil }
        guard let JSON = JSON as? [String: Any],
            let read = JSON["READ"] as? Bool,
            let owner = JSON["OWNER"] as? Bool,
            let mount = JSON["MOUNT"] as? Bool,
            let create_receiver = JSON["CREATE_RECEIVER"] as? Bool,
            let comment = JSON["COMMENT"] as? Bool,
            let write = JSON["WRITE"] as? Bool,
            let create_link = JSON["CREATE_LINK"] as? Bool
            else {
                print("Couldnt parse Permissions JSON.")
                return nil
        }

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
