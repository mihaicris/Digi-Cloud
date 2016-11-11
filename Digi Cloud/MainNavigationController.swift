//
//  MainNavigationController.swift
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


        // we check if app is launched for the first time, if yes, we initialize some settings
        if !UserDefaults.standard.getIsAppFirstTimeStarted() {

            // Set that App has been started first time
            UserDefaults.standard.setIsAppFirstTimeStarted(value: true)

            // Set that sorting the content of the folder will show folders first
            UserDefaults.standard.setShowFoldersFirst(value: true)
        }

        // if there is a token saved, we load the locations, otherwise present the login screen
        if let token = UserDefaults.standard.getLoginToken() {
            DigiClient.shared.token = token
            let controller = LocationsTableViewController()
            viewControllers = [controller]
        } else {
            // present modally the login view, after a very small delay
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.milliseconds(50), execute: {
                let controller = LoginViewController()
                controller.onFinish = {
                    DispatchQueue.main.async {
                        self.viewControllers = [LocationsTableViewController()]
                        self.dismiss(animated: true, completion: nil) // dismiss LoginViewController
                    }
                }
                self.present(controller, animated: true, completion: nil)
            })
        }
    }
}
