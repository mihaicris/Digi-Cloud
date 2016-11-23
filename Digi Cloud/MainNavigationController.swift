//
//  MainNavigationController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 18/10/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class MainNavigationController: UINavigationController {

    // MARK: - Overridden Methods and Properties

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        // we check if app is launched for the first time, if yes, we initialize some settings
        if !AppSettings.isAppFirstTimeStarted {

            // Set that App has been started first time
            AppSettings.isAppFirstTimeStarted = true

            // Set sorting defaults
            AppSettings.showFoldersFirst = true
            AppSettings.sortMethod = .byName
            AppSettings.sortAscending = true

        }

        // if there is a token saved, we load the locations, otherwise present the login screen
        if let token = AppSettings.loginToken {
            DigiClient.shared.token = token

            // TODO: Show activity indicator

            DigiClient.shared.getUserInfo {
                json, statusCode, error in

                guard error == nil || statusCode == 200 else {
                    print(error!.localizedDescription)
                    print("StatusCode: \(statusCode)")
                    DigiClient.shared.token = nil
                    self.showLoginScreen()
                    return
                }
                DispatchQueue.main.async {
                    let controller = LocationsTableViewController(action: .noAction)
                    self.viewControllers = [controller]
                }
            }
        } else {
            showLoginScreen()
        }

    }

    // MARK: - Helper Functions

    func showLoginScreen() {
        // present modally the login view, after a very small delay
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.milliseconds(50), execute: {
            let controller = LoginViewController()
            controller.onFinish = {
                DispatchQueue.main.async {
                    self.viewControllers = [LocationsTableViewController(action: .noAction)]
                    self.dismiss(animated: true, completion: nil) // dismiss LoginViewController
                }
            }
            self.present(controller, animated: true, completion: nil)
        })
    }
}
