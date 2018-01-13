//
//  AppDelegate.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 15/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private var flowController: FlowController!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        #if !DEBUG
        // Start Crashlytics
        Fabric.with([Crashlytics.self])
        #endif

        // Get a window
        window = UIWindow(frame: UIScreen.main.bounds)

        // Init flow manager
        self.flowController = FlowController(window: self.window!)

        window?.backgroundColor = .white
        window?.rootViewController = self.flowController.rootController()
        window?.makeKeyAndVisible()

        createWorkingFolders()

        return true
    }

    private func createWorkingFolders() {
        FileManager.createProfileImagesCacheFolder()
        FileManager.createFilesCacheFolder()
    }
}
