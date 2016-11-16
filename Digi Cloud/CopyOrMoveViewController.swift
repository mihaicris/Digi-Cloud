//
//  MoveTableViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 15/11/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class CopyOrMoveViewController: UIViewController {

    var onFinish: ((Void) -> Void)?

    var element: Element
    var action: ActionType

    init(element: Element, action: ActionType) {
        self.element = element
        self.action = action
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

        switch action {
        case .copy:
            self.title = element.type == "file" ? NSLocalizedString("Copy File", comment: "Window title") : NSLocalizedString("Copy Folder", comment: "Window title")
        case .move:
            self.title = element.type == "file" ? NSLocalizedString("Move File", comment: "Window title") : NSLocalizedString("Move Folder", comment: "Window title")
        default:
            return
        }

        let rightButton = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: "Button Title"), style: UIBarButtonItemStyle.done, target: self, action: #selector(handleDone))

        navigationItem.setRightBarButton(rightButton, animated: false)

    }

    @objc private func handleDone() {
        self.onFinish?()
    }
}
