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
}

extension User {
    init?(JSON: Any?) {
        if JSON == nil { return nil }
        guard let JSON = JSON as? [String: Any],
            let id = JSON["id"] as? String,
            let name = JSON["name"] as? String,
            let email = JSON["email"] as? String else {
                print("Error at parsing of User JSON.")
                return nil
        }
        self.id = id
        self.name = name
        self.email = email
    }
}

extension User: CustomStringConvertible {
    var description: String {
        return  "Id:\t\t\t\(id)\n"
                + "Name:\t\t\(name)\n"
                + "Email:\t\t\(email)\n"
    }
}
