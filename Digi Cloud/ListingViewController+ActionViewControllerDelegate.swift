//
//  FilesTableViewController+ActionsViewControllerDelegate.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 07/11/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

extension ListingViewController: ActionViewControllerDelegate {
    func didSelectOption(action: ActionType) {

        self.animateActionButton(active: false)
        dismiss(animated: true, completion: nil) // dismiss ActionsViewController

        let node = content[currentIndex.row]

        switch action {
        case .rename:
            let controller = RenameViewController(location: location, node: node)
            controller.onFinish = { (newName, needRefresh) in

                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil) // dismiss RenameViewController
                }
                if let name = newName {

                    self.content[self.currentIndex.row] = Node(name:        name,
                                                               type:        node.type,
                                                               modified:    node.modified,
                                                               size:        node.size,
                                                               contentType: node.contentType)
                    self.sortContent()
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } else {
                    if needRefresh {
                        self.getFolderContent()
                    }
                }
            }
            let navController = UINavigationController(rootViewController: controller)
            navController.modalPresentationStyle = .formSheet
            present(navController, animated: true, completion: nil)

        case .copy, .move:

            guard let previousControllers = navigationController?.viewControllers else {
                print("Couldn't get the previous navigation controllers!")
                return
            }

            var controllers: [UIViewController] = []

            for (index, p) in previousControllers.enumerated() {

                // If index is 0 than this is a location controller
                if index == 0 {
                    let c = LocationsTableViewController(action: action)
                    c.title = NSLocalizedString("Locations", comment: "Window Title")
                    c.onFinish = { [unowned self] in
                        self.dismiss(animated: true, completion: nil)
                        if self.needRefresh {
                            self.getFolderContent()
                        }
                    }
                    controllers.append(c)
                }

                // we need to cast in order to tet the mountID and path from it
                if let p = p as? ListingViewController {
                    var node: Node?

                    // If index is the last one, we need to inject the current node which is
                    // moved or copied, such that it won't be shown in the list.
                    if index == previousControllers.count - 1 {
                        node = content[currentIndex.row]
                    }

                    let c = CopyOrMoveViewController(location: p.location, node: node, action: action)
                    c.title = p.title
                    c.onFinish = { [unowned self] in
                        self.dismiss(animated: true, completion: nil)
                        if self.needRefresh {
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                                self.getFolderContent()
                            }
                        }
                    }
                    controllers.append(c)
                }
            }

            let navController = UINavigationController(navigationBarClass: CustomNavBar.self, toolbarClass: nil)
            navController.setViewControllers(controllers, animated: false)
            navController.modalPresentationStyle = .formSheet
            present(navController, animated: true, completion: nil)

        case .delete:

            if node.type == "file" {
                let controller = DeleteViewController(node: node)
                controller.delegate = self

                // position alert on the same row with the file
                var sourceView = tableView.cellForRow(at: currentIndex)!.contentView
                for view in sourceView.subviews {
                    if view.tag == 1 {
                        sourceView = view.subviews[0]
                    }
                }
                controller.modalPresentationStyle = .popover
                controller.popoverPresentationController?.sourceView = sourceView
                controller.popoverPresentationController?.sourceRect = sourceView.bounds
                present(controller, animated: true, completion: nil)
            }

        case .folderInfo:
            let controller = FolderInfoViewController(location: self.location, node: node)
            controller.onFinish = { (success, needRefresh) in
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil) // dismiss FolderViewController
                    if success {
                        self.content.remove(at: self.currentIndex.row)
                        self.tableView.deleteRows(at: [self.currentIndex], with: .left)
                    } else {
                        if needRefresh {
                            self.getFolderContent()
                        }
                    }
                }
            }
            let navController = UINavigationController(rootViewController: controller)
            navController.modalPresentationStyle = .formSheet
            present(navController, animated: true, completion: nil)

        default:
            return
        }
    }
}

class CustomNavBar: UINavigationBar {
    
    // I don't like the animation of the nav title when presented on a formsheet modal presentation style
    override func popItem(animated: Bool) -> UINavigationItem? {
        return super.popItem(animated: false)
    }
}
