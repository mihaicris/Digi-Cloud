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

    private init() {}

    static let shared: AppSettings = AppSettings()

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

    static var loggedAccount: String? {
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
