//
//  UIApplication+DigiCloud.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 17/01/17.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import UIKit.UIApplication

extension UIApplication {
    class var Build: String {
        get {
            return Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String ?? ""
        }
    }

    class var Version: String {
        get {
            return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        }
    }
}
