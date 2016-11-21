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
            // TODO: Refactor sort, refresh

            let controller = RenameViewController(mountID: self.mountID, path: self.path, node: node)
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

            // TODO: Prepare the stack of CopyOrMoveViewControllers
            guard let parentTitle = self.title else {
                print("Could not get root folder title")
                return
            }

            let controller = CopyOrMoveViewController(mountID: self.mountID,
                                                      path: self.path,
                                                      node: node,
                                                      action: action,
                                                      parentTitle: parentTitle,
                                                      backButtonTitle: backButtonTitle)
            controller.onFinish = { [unowned self] in
                self.dismiss(animated: true, completion: nil)
                if self.needRefresh {
                    self.getFolderContent()
                }
            }

            let navController = UINavigationController(rootViewController: controller)
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
            let controller = FolderInfoViewController(mountID: self.mountID, path: self.path, node: node)
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
