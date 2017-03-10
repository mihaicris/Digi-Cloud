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
        INITLog(self)
    }

    deinit { DEINITLog(self) }

    // MARK: - Overridden Methods and Properties

    // MARK: - Helper Functions

    func rootController() -> UIViewController {

        var controller: UIViewController

        if AppSettings.hasRunBefore {
//            if AppSettings.shouldReplayIntro {
//                controller = self.createIntroController()
//            } else {
                if let username = AppSettings.loggedAccount {
                    let loggedAccount = Account(username: username)
                    do {
                        let token = try loggedAccount.readToken()
                        DigiClient.shared.token = token
                        controller = self.createMainNavigationController()
                    } catch {
                        controller = self.createAccountSelectionController()
                    }
                } else {
                    controller = self.createAccountSelectionController()
                }
//            }
        } else {
            AppSettings.clearKeychainItems()
            AppSettings.setDefaultAppSettings() // Move this in IntroController.
//            controller = self.createIntroController()
            controller = self.createAccountSelectionController()
        }
        return controller
    }

    private func createIntroController() -> UIViewController {

        let controller = IntroductionViewController()

        controller.onFinish = { [weak self] in
            guard let navController = controller.navigationController else { return }
            guard let userSelectionController = self?.createAccountSelectionController() else { return }
            navController.pushViewController(userSelectionController, animated: true)

            // IntroViewController is removed from the stack
            _ = navController.viewControllers.dropFirst()
        }

        let navController = UINavigationController(rootViewController: controller)
        navController.setNavigationBarHidden(true, animated: false)
        return navController
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
