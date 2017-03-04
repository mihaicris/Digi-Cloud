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
    let permissions: Set<Permission>
}

extension User: CustomStringConvertible {
    var description: String {
        return  "Id:\t\t\t\(id)\n" +
            "Name:\t\t\(name)\n" +
            "Email:\t\t\(email)\n" +
        "Permissions:\t\(permissions)"
    }
}
