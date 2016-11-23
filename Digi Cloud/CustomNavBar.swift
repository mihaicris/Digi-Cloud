//
//  CustomNavBar.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 23/11/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class CustomNavBar: UINavigationBar {

    // Cancell animation for navigationItem when presented on a formsheet modal presentation style
    override func popItem(animated: Bool) -> UINavigationItem? {
        return super.popItem(animated: false)
    }
}
