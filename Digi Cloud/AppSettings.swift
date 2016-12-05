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

final class AppSettings {

    // MARK: - Properties
    static let shared: AppSettings = AppSettings()
    static var tableViewRowHeight: CGFloat = 50
    fileprivate init() {}
    static var isAppFirstTimeStarted: Bool {
        get {
            return UserDefaults.standard.bool(forKey: UserDefaults.UserDefaultsKeys.isAppFirstTimeStarted.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaults.UserDefaultsKeys.isAppFirstTimeStarted.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
    static var isLoggedIn: Bool {
        get {
            return UserDefaults.standard.bool(forKey: UserDefaults.UserDefaultsKeys.isLoggedIn.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaults.UserDefaultsKeys.isLoggedIn.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
    static var loginToken: String? {
        get {
            return UserDefaults.standard.string(forKey: UserDefaults.UserDefaultsKeys.loginToken.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaults.UserDefaultsKeys.loginToken.rawValue)
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
