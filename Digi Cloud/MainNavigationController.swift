//
//  MainnavigationController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 18/10/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class MainNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        if let token = UserDefaults.standard.getLoginToken() {
            DigiClient.shared.token = token
            let controller = LocationsTableViewController()
            viewControllers = [controller]
        } else {
            // present modally the login view, after a very small delay
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.milliseconds(50), execute: {
                let controller = LoginViewController()
                self.present(controller, animated: true, completion: nil)
            })
        }
    }
}
