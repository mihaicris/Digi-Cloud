//
//  FlowController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 05/01/17.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import UIKit

class FlowController {

    fileprivate var window: UIWindow

    init(window: UIWindow) {
        self.window = window
    }

    func rootController() -> UIViewController {

        var controller: UIViewController

        if AppSettings.hasRunBefore {
            if AppSettings.shouldReplayIntro {
                controller = self.createIntroController()
            } else {
                if let account = AppSettings.loggedAccount {
                    let loggedAccount = Account(account: account)
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
            }
        } else {
            AppSettings.clearKeychainItems()
            controller = self.createIntroController()
        }
        return controller
    }

    fileprivate func createIntroController() -> UIViewController {

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

    fileprivate func createAccountSelectionController() -> UIViewController {
        let controller = AccountSelectionViewController()
        controller.onSelect = { [weak self] in
            self?.transitionToNewRootController()
        }
        return controller
    }

    fileprivate func createMainNavigationController() -> UIViewController {
        let controller = MainNavigationController()
        controller.onLogout = { [weak self] in
            self?.transitionToNewRootController()
        }
        return controller
    }

    private func transitionToNewRootController() {
        UIView.animate(withDuration: 0.1, animations: {
            self.window.alpha = 0.0
        }, completion: { (_) in
            self.window.rootViewController = self.rootController()
            UIView.animate(withDuration: 0.05, animations: {
                self.window.alpha = 1.0
            })
        })
    }

}
