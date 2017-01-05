//
//  UserDefaults+DigiCloud.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 05/01/17.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import Foundation.NSUserDefaults

extension UserDefaults {

    enum UserDefaultsKeys: String {
        case wasAppStarted
        case userLogged
        case loginToken
        case showFoldersFirst
        case sortMethod
        case sortAscending
    }

}
