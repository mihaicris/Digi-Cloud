//
//  AppSettings.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 02/11/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

struct AppSettings {

    // MARK: - Properties

    static var tableViewRowHeight: CGFloat = 50

    static var hasRunBefore: Bool {
        get {
            return UserDefaults.standard.bool(forKey: UserDefaults.UserDefaultsKeys.hasRunBefore.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaults.UserDefaultsKeys.hasRunBefore.rawValue)
            UserDefaults.standard.synchronize()
        }
    }

    static var shouldReplayIntro: Bool {
        get {
            return UserDefaults.standard.bool(forKey: UserDefaults.UserDefaultsKeys.shouldReplayIntro.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaults.UserDefaultsKeys.shouldReplayIntro.rawValue)
            UserDefaults.standard.synchronize()
        }
    }

    static var loggedUserID: String? {
        get {
            return UserDefaults.standard.string(forKey: UserDefaults.UserDefaultsKeys.userLogged.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaults.UserDefaultsKeys.userLogged.rawValue)
            UserDefaults.standard.synchronize()
        }
    }

    static var showsFoldersFirst: Bool {
        get {
            return UserDefaults.standard.bool(forKey: UserDefaults.UserDefaultsKeys.showsFoldersFirst.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaults.UserDefaultsKeys.showsFoldersFirst.rawValue)
            UserDefaults.standard.synchronize()
        }
    }

    static var sortMethod: SortMethodType {
        get {
            let value = UserDefaults.standard.integer(forKey: UserDefaults.UserDefaultsKeys.sortMethod.rawValue)
            return SortMethodType(rawValue: value)!
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: UserDefaults.UserDefaultsKeys.sortMethod.rawValue)
            UserDefaults.standard.synchronize()
        }
    }

    static var sortAscending: Bool {
        get {
            return UserDefaults.standard.bool(forKey: UserDefaults.UserDefaultsKeys.sortAscending.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaults.UserDefaultsKeys.sortAscending.rawValue)
            UserDefaults.standard.synchronize()

        }
    }

    static var allowsCellularAccess: Bool {
        get {
            return UserDefaults.standard.bool(forKey: UserDefaults.UserDefaultsKeys.allowsCellularAccess.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaults.UserDefaultsKeys.allowsCellularAccess.rawValue)
            UserDefaults.standard.synchronize()

        }
    }

    static func tokenForAccount(account: Account) -> String {
        return try! account.readToken()
    }

    static func persistUserInfo(user: User) {
        UserDefaults.standard.set(user.name, forKey: "name-\(user.id)")
        UserDefaults.standard.set(user.email, forKey: "email-\(user.id)")
        UserDefaults.standard.synchronize()
    }

    static func getPersistedUserInfo(userID: String) -> User? {
        guard let name  = UserDefaults.standard.string(forKey: "name-\(userID)"),
              let email = UserDefaults.standard.string(forKey: "email-\(userID)") else {
            return nil
        }
        return User(id: userID, name: name, email: email, permissions: Permissions())
    }

    static func deletePersistedUserInfo(userID: String) {
        UserDefaults.standard.set(nil, forKey: "name-\(userID)")
        UserDefaults.standard.set(nil, forKey: "email-\(userID)")
        UserDefaults.standard.synchronize()
    }

    static func saveUser(forToken token: String, completion: @escaping (User?, Error?) -> Void) {

        DigiClient.shared.getUser(forToken: token) { userResult, error in

            guard error == nil else {
                completion(nil, error)
                return
            }

            guard let user = userResult else {
                completion(nil, error)
                return
            }

            let account = Account(userID: user.id)

            do {
                try account.save(token: token)
            } catch {
                fatalError("Couldn't write to KeyChain")
            }

            persistUserInfo(user: user)

            DigiClient.shared.loggedAccount = account

            DigiClient.shared.getUserProfileImage(for: user) { image, error in

                guard error == nil else {
                    return
                }

                let cache = Cache()

                let key = user.id + ".png"

                if let image = image, let data = UIImagePNGRepresentation(image) {
                    cache.save(type: .profile, data: data, for: key)
                }

                completion(user, nil)
            }
        }
    }

    static func clearKeychainItems() {
        do {
            let accounts = try Account.accountItems()
            for account in accounts {
                try account.deleteItem()
            }
        } catch {
            fatalError("There was an error while deleting the existing Keychain account stored tokens.")
        }
    }

    static func setDefaultAppSettings() {

        // Set that App has been started for the first time
        hasRunBefore = true

        // Sorting settings
        showsFoldersFirst = true
        sortMethod = .byName
        sortAscending = true

        // Network settings
        allowsCellularAccess = false
    }
}
