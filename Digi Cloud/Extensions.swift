//
//  Extensions.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 23/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    var contentViewController: UIViewController {
        if let navigationController = self as? UINavigationController {
            return navigationController.visibleViewController ?? self
        } else {
            return self
        }
    }
}

extension UIView {

    func addConstraints(with format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
}

extension UserDefaults {

    enum UserDefaultsKeys: String {
        case isAppFirstTimeStarted
        case isLoggedIn
        case showFoldersFirst
        case sortMethodOption
    }

    func setIsAppFirstTimeStarted(value: Bool) {
        set(value, forKey: UserDefaultsKeys.isAppFirstTimeStarted.rawValue)
        synchronize()
    }

    func getIsAppFirstTimeStarted() -> Bool {
        return bool(forKey: UserDefaultsKeys.isAppFirstTimeStarted.rawValue)
    }

    func setLoginToken(value: String) {
        set(value, forKey: UserDefaultsKeys.isLoggedIn.rawValue)
        synchronize()
    }

    func getLoginToken() -> String? {
        return string(forKey: UserDefaultsKeys.isLoggedIn.rawValue)
    }

    func setShowFoldersFirst(value: Bool) {
        set(value, forKey: UserDefaultsKeys.showFoldersFirst.rawValue)
        synchronize()
    }

    func getShowFoldersFirst() -> Bool {
        return bool(forKey: UserDefaultsKeys.showFoldersFirst.rawValue)
    }


}

extension UIColor {
    static var defaultColor: UIColor {
        return UIColor(colorLiteralRed: 6/255, green: 96/255, blue: 254/255, alpha: 1.0)
    }
}
