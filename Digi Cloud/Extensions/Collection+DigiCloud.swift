//
//  Collection.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 16/03/2017.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

extension Collection where Iterator.Element == User {

    func updating(from changedUsers: [User]) -> [User] {

        var updatedUsers: [User] = []

        for oldElem in self {
            if let indexF = changedUsers.index(where: { (changedElem) -> Bool in
                changedElem.identifier == oldElem.identifier
            }) {
                updatedUsers.append(changedUsers[indexF])
            } else {
                updatedUsers.append(oldElem)
            }
        }

        return updatedUsers
    }
}
