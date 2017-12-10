//
//  User.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 04/03/2017.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

struct User {
    let identifier: String
    let firstName: String
    let lastName: String
    var email: String
    var permissions: Permissions
}

extension User {
    init?(object: Any?) {
        guard
            let jsonDictionary = object as? [String: Any],
            let identifier = jsonDictionary["id"] as? String,
            let name = jsonDictionary["name"] as? String,
            let email = jsonDictionary["email"] as? String
            else { return nil }

        if let permissions = Permissions(object: jsonDictionary["permissions"]) {
            self.permissions = permissions
        } else {
            return nil
        }

        self.identifier = identifier

        let nameComponents = name.components(separatedBy: " ")

        if nameComponents.count == 1 {
            self.firstName = nameComponents.first!
            self.lastName = ""
        } else if nameComponents.count == 2 {
            self.firstName = nameComponents.first!
            self.lastName = nameComponents.last!
        } else {
            self.firstName = nameComponents.first!
            self.lastName = nameComponents.dropFirst().joined(separator: " ")
        }

        self.email = email
    }

    init?(infoJSON: Any?) {
        if infoJSON == nil { return nil }
        guard let JSON = infoJSON as? [String: Any],
            let id = JSON["id"] as? String,
            let firstName = JSON["firstName"] as? String,
            let lastName = JSON["lastName"] as? String,
            let email = JSON["email"] as? String
            else {
                print("Error at parsing of User infoJSON.")
                return nil
        }

        self.identifier = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.permissions = Permissions()
    }
}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.email == rhs.email
    }

}
