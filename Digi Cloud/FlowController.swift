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

        if AppSettings.wasAppStarted {
            if let account = AppSettings.accountLoggedIn {
                DigiClient.shared.token = AppSecurity.getToken(account: account)
                controller = self.createMainNavigationController()
            } else {
                controller = self.createAccountSelectionController()
            }
        } else {
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

        let controller = AccountSelectionViewController(collectionViewLayout: UICollectionViewLayout())
        controller.onSelect = { [weak self] in
            self?.window.rootViewController = self?.rootController()
        }

        return controller
    }

    fileprivate func createMainNavigationController() -> UIViewController {
        let controller = MainNavigationController()
        controller.onLogout = { [weak self] in
            self?.window.rootViewController = self?.rootController()
        }
        return controller
    }

}
