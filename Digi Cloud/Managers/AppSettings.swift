//
//  AppSettings.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 02/11/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class AppSettings {

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

    static var userLogged: User? {
        if let userID = loggedUserID {
            if let user = getPersistedUserInfo(userID: userID) {
                return user
            }
        }
        return nil
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

    static var shouldPasswordDownloadLink: Bool {
        get {
            return UserDefaults.standard.bool(forKey: UserDefaults.UserDefaultsKeys.shouldPasswordDownloadLink.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaults.UserDefaultsKeys.shouldPasswordDownloadLink.rawValue)
            UserDefaults.standard.synchronize()
        }
    }

    static var shouldPasswordReceiveLink: Bool {
        get {
            return UserDefaults.standard.bool(forKey: UserDefaults.UserDefaultsKeys.shouldPasswordReceiveLink.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaults.UserDefaultsKeys.shouldPasswordReceiveLink.rawValue)
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

        guard let token = try? account.readToken() else {
            AppSettings.showErrorMessageAndCrash(
                title: NSLocalizedString("Error reading account from Keychain", comment: ""),
                subtitle: NSLocalizedString("The app will now close", comment: "")
            )
            return ""
        }

        return token
    }

    static func persistUserInfo(user: User) {
        UserDefaults.standard.set(user.firstName, forKey: "firstName-\(user.id)")
        UserDefaults.standard.set(user.lastName, forKey: "lastName-\(user.id)")
        UserDefaults.standard.set(user.email, forKey: "email-\(user.id)")
        UserDefaults.standard.synchronize()
    }

    static func getPersistedUserInfo(userID: String) -> User? {
        guard let firstName  = UserDefaults.standard.string(forKey: "firstName-\(userID)"),
              let lastName = UserDefaults.standard.string(forKey: "lastName-\(userID)"),
              let email = UserDefaults.standard.string(forKey: "email-\(userID)") else {
            return nil
        }
        return User(id: userID, firstName: firstName, lastName: lastName, email: email, permissions: Permissions())
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
                AppSettings.showErrorMessageAndCrash(
                    title: NSLocalizedString("Error saving account to Keychain", comment: ""),
                    subtitle: NSLocalizedString("The app will now close", comment: "")
                )
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
            AppSettings.showErrorMessageAndCrash(
                title: NSLocalizedString("Error deleting account from Keychain", comment: ""),
                subtitle: NSLocalizedString("The app will now close", comment: "")
            )
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
        allowsCellularAccess = true
    }

    static func showErrorMessageAndCrash(title: String, subtitle: String) {

        if let window = UIApplication.shared.keyWindow {
            let blackView = UIView()
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            window.addSubview(blackView)
            blackView.frame = window.frame
            blackView.alpha = 0.0

            let frameAlert: UIView = {
                let v = UIView()
                v.translatesAutoresizingMaskIntoConstraints = false
                v.backgroundColor = UIColor.black.withAlphaComponent(0.85)
                v.layer.cornerRadius = 10
                v.layer.borderWidth = 0.6
                v.layer.borderColor = UIColor(red: 0.8, green: 0.0, blue: 0.0, alpha: 1.0).cgColor
                v.clipsToBounds = true
                return v
            }()

            let titleMessageLabel: UILabel = {
                let l = UILabel()
                l.translatesAutoresizingMaskIntoConstraints = false
                l.font = UIFont.HelveticaNeueLight(size: 24)
                l.textColor = UIColor.white
                l.text = title
                l.textAlignment = .center
                l.numberOfLines = 2
                return l
            }()

            let subtitleMessageLabel: UILabel = {
                let l = UILabel()
                l.translatesAutoresizingMaskIntoConstraints = false
                l.font = UIFont.HelveticaNeueLight(size: 18)
                l.textColor = UIColor.white
                l.text = subtitle
                l.textAlignment = .center
                l.textColor = UIColor.lightGray
                l.numberOfLines = 3
                return l
            }()

            let okButton: UIButton = {
                let b = UIButton(type: UIButtonType.system)
                b.translatesAutoresizingMaskIntoConstraints = false
                b.backgroundColor = UIColor(red: 0.9, green: 0.0, blue: 0.0, alpha: 1.0)
                b.layer.cornerRadius = 10
                b.layer.masksToBounds = true
                b.setTitle(NSLocalizedString("OK", comment: ""), for: .normal)
                b.setTitleColor(UIColor.white, for: .normal)
                b.contentEdgeInsets = UIEdgeInsets(top: 2, left: 15, bottom: 3, right: 15)
                b.addTarget(self, action: #selector(handleCrash), for: .touchUpInside)
                return b
            }()

            blackView.addSubview(frameAlert)
            frameAlert.addSubview(titleMessageLabel)
            frameAlert.addSubview(subtitleMessageLabel)
            frameAlert.addSubview(okButton)

            NSLayoutConstraint.activate([
                frameAlert.centerXAnchor.constraint(equalTo: blackView.centerXAnchor),
                frameAlert.centerYAnchor.constraint(equalTo: blackView.centerYAnchor),
                frameAlert.widthAnchor.constraint(equalToConstant: 600),
                frameAlert.heightAnchor.constraint(equalToConstant: 200),

                titleMessageLabel.leftAnchor.constraint(equalTo: frameAlert.layoutMarginsGuide.leftAnchor),
                titleMessageLabel.rightAnchor.constraint(equalTo: frameAlert.layoutMarginsGuide.rightAnchor),
                titleMessageLabel.centerYAnchor.constraint(equalTo: frameAlert.centerYAnchor, constant: -30),

                subtitleMessageLabel.leftAnchor.constraint(equalTo: frameAlert.layoutMarginsGuide.leftAnchor),
                subtitleMessageLabel.rightAnchor.constraint(equalTo: frameAlert.layoutMarginsGuide.rightAnchor),
                subtitleMessageLabel.topAnchor.constraint(equalTo: titleMessageLabel.bottomAnchor, constant: 10),

                okButton.centerXAnchor.constraint(equalTo: frameAlert.centerXAnchor),
                okButton.bottomAnchor.constraint(equalTo: frameAlert.bottomAnchor, constant: -20)
             ])

            UIView.animate(withDuration: 0.5) { blackView.alpha = 1 }

        }
    }

    @objc private func handleCrash() {
        fatalError()
    }
}
