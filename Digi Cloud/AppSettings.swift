//
//  AppSettings.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 02/11/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

enum SortMethodType: Int {
    case byName = 1
    case byDate
    case bySize
    case byContentType
}

struct AppSettings {

    // MARK: - Properties
    static let shared: AppSettings = AppSettings()
    static var tableViewRowHeight: CGFloat = 50
    fileprivate init() {}
    static var wasAppStarted: Bool {
        get {
            return UserDefaults.standard.bool(forKey: UserDefaults.UserDefaultsKeys.wasAppStarted.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaults.UserDefaultsKeys.wasAppStarted.rawValue)
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

    static var showFoldersFirst: Bool {
        get {
            return UserDefaults.standard.bool(forKey: UserDefaults.UserDefaultsKeys.showFoldersFirst.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaults.UserDefaultsKeys.showFoldersFirst.rawValue)
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
        get { return UserDefaults.standard.bool(forKey: UserDefaults.UserDefaultsKeys.sortAscending.rawValue) }
        set { UserDefaults.standard.set(newValue, forKey: UserDefaults.UserDefaultsKeys.sortAscending.rawValue) }
    }
}
