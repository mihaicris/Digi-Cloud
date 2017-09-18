//
//  UIApplication+DigiCloud.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 17/01/17.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import Foundation

extension Bundle {
    
    var versionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    var buildNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
    
    var prettyVersionString: String {
        let ver = versionNumber ?? NSLocalizedString("Unknown", comment: "")
        let build = buildNumber ?? "0"
        let format = NSLocalizedString("Digi Cloud\nVersion %@ (%@)", comment: "")
        return  String.localizedStringWithFormat(format, ver, build)
    }
    
}
