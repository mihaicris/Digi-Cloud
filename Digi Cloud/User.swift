//
//  User.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 04/03/2017.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

struct User {
    let id: String
    let name: String
    let email: String
    let permissions: Permissions
}

extension User {

    init?(JSON: Any?) {
        if JSON == nil { return nil }
        guard let JSON = JSON as? [String: Any],
            let id = JSON["id"] as? String,
            let name = JSON["name"] as? String,
            let email = JSON["email"] as? String
            else {
                print("Error at parsing of User JSON.")
                return nil
        }

        if let permissions = Permissions(JSON: JSON["permissions"]) {
            self.permissions = permissions
        } else {
            return nil
        }

        self.id = id
        self.name = name
        self.email = email
    }
}
