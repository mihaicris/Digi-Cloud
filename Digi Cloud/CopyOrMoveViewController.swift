//
//  MoveTableViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 15/11/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class CopyOrMoveViewController: UITableViewController {

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

        var buttonTitle: String

        switch action {
        case .copy:
            self.title = element.type == "file" ? NSLocalizedString("Copy File", comment: "Window title") : NSLocalizedString("Copy Folder", comment: "Window title")
            buttonTitle = NSLocalizedString("Copy here", comment: "Button Title")
        case .move:
            self.title = element.type == "file" ? NSLocalizedString("Move File", comment: "Window title") : NSLocalizedString("Move Folder", comment: "Window title")
            buttonTitle = NSLocalizedString("Move here", comment: "Button Title")
        default:
            return
        }

        let rightButton = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: "Button Title"), style: UIBarButtonItemStyle.done, target: self, action: #selector(handleDone))
        navigationItem.setRightBarButton(rightButton, animated: false)

        navigationController?.isToolbarHidden = false

        let toolBarItems = [UIBarButtonItem(title: NSLocalizedString("New Folder", comment: "Button Title"), style: .plain, target: self, action: #selector(handleNewFolder)),
                            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                            UIBarButtonItem(title: buttonTitle, style: .plain, target: self, action: #selector(handleCopyOrMove))]

        self.setToolbarItems(toolBarItems, animated: true)

    }

    @objc private func handleDone() {
        self.onFinish?()
    }

    @objc private func handleNewFolder() {
        self.onFinish?()
    }

    @objc private func handleCopyOrMove() {

        guard let currentMount = DigiClient.shared.currentMount else { return }
        guard let currentPath = DigiClient.shared.currentPath.last else { return }

        let elementSourcePath = currentPath + element.name
        let destinationMount = currentMount  // TODO: Update with destination mount
        let elementDestinationPath = currentPath + element.name  // TODO: Update with selected destination path (without element name inside)

        return
        DigiClient.shared.copyOrMoveElement(action:             action,
                                            path:               elementSourcePath,
                                            toMountId:          destinationMount,
                                            toPath:             elementDestinationPath,
                                            completionHandler:  {(statusCode, error) in return })
    }
}
