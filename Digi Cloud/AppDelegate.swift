//
//  AppDelegate.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 15/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    fileprivate var flowController: FlowController!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        // Get a window
        window = UIWindow(frame: UIScreen.main.bounds)

        // Init flow manager
        self.flowController = FlowController(window: self.window!)

        window?.backgroundColor = .white
        window?.rootViewController = self.flowController.rootController()
        window?.makeKeyAndVisible()

        #if DEBUG
        let documentsDir = FileManager.documentsDir()
        DLog(name: "Documents Directory", object: documentsDir)
        let cachesDir = FileManager.cachesDir()
        DLog(name: "Caches Directory", object: cachesDir)
        #endif

        return true
    }
}
