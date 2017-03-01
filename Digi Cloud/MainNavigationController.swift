//
//  MainNavigationController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 18/10/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class MainNavigationController: UINavigationController {

    // MARK: - Properties
    
    // Closure called when user has logged out.
    var onLogout: (() -> Void)?

    // This property will hold the source node when copying or moving action
    // It can be accessed by any view controller on the stack of controllers
    var sourceNodes: [Node]?

    // The view controller index where the search controller has been initiated.
    // Following search actions will be routed to this view controller
    var searchResultsControllerIndex: Int?

    // MARK: - Initializers and Deinitializers
    
    deinit { DEINITLog(self) }

    // MARK: - Overridden Methods and Properties

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let controller = LocationsViewController(action: .noAction)
        pushViewController(controller, animated: false)
    }

}
