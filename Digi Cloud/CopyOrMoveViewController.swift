//
//  MoveTableViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 15/11/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class CopyOrMoveViewController: UIViewController {

    fileprivate var element: File
    fileprivate var operation: Int

    init(element: File, operation: Int) {
        self.element = element
        self.operation = operation
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    private func setupViews() {
        view.backgroundColor = UIColor.white

        if operation == 3 {
            self.title = element.type == "file" ? NSLocalizedString("Copy File", comment: "Window title") : NSLocalizedString("Copy Folder", comment: "Window title")
        } else if operation == 4 {
            self.title = element.type == "file" ? NSLocalizedString("Move File", comment: "Window title") : NSLocalizedString("Move Folder", comment: "Window title")
        }
    }

}
