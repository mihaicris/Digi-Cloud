//
//  FlowController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 05/01/17.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import UIKit

final class FlowController {

    // MARK: - Properties

    private var window: UIWindow

    // MARK: - Initializers and Deinitializers

    init(window: UIWindow) {
        self.window = window
    }

    // MARK: - Overridden Methods and Properties

    // MARK: - Helper Functions

    func rootController() -> UIViewController {

        var controller: UIViewController

        if AppSettings.hasRunBefore {
            if let userID = AppSettings.loggedUserID {

                let account = Account(userID: userID)

                DigiClient.shared.loggedAccount = account

                controller = self.createMainNavigationController()

            } else {
                controller = self.createAccountSelectionController()
            }
        } else {
            AppSettings.clearKeychainItems()
            AppSettings.setDefaultAppSettings()
            controller = self.createAccountSelectionController()
        }
        return controller
    }

    private func createAccountSelectionController() -> UIViewController {
        let controller = AccountSelectionViewController()
        controller.onSelect = { [weak self] in
            self?.window.rootViewController = self?.rootController()
        }
        return controller
    }

    private func createMainNavigationController() -> UIViewController {
        let controller = MainNavigationController()
        controller.onLogout = { [weak self] in
            self?.window.rootViewController = self?.rootController()
        }
        return controller
    }
}
