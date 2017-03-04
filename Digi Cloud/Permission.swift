//
//  Permission.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 04/03/2017.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

enum Permission: String {
    case read = "READ"
    case write = "WRITE"
    case comment = "COMMENT"
    case owner = "OWNER"
    case mount = "MOUNT"
    case create_receiver = "CREATE_RECEIVER"
    case create_link = "CREATE_LINK"
    case create_action = "CREATE_ACTION"
}

extension Permission: CustomStringConvertible {
    var description: String {
        return self.rawValue
    }
}
