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
    let mount: Bool
    let create_receiver: Bool
    let comment: Bool
    let write: Bool
    let create_link: Bool
}

extension Permissions {
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
}
