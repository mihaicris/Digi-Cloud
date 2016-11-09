//
//  FilesTableViewController+ActionsViewControllerDelegate.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 07/11/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

extension ListingViewController: ChooseElementActionViewControllerDelegate {
    func didSelectOption(tag: Int) {
        self.animateActionButton(active: false)
        dismiss(animated: true, completion: nil) // dismiss ActionsViewController
        switch tag {
        // rename action
        case 2:
            // TODO: Refactor sort, refresh
            let controller = RenameViewController(element: content[currentIndex.row])
            controller.onFinish = { [weak self] (newName, needRefresh) in
                if let vc = self {
                    DispatchQueue.main.async {
                        vc.dismiss(animated: true, completion: nil) // dismiss RenameViewController
                        if let name = newName{
                            vc.content[vc.currentIndex.row].name = name
                            vc.sortContent()
                            vc.tableView.reloadData()
                        } else {
                            if needRefresh {
                                vc.getFolderContent()
                            }
                        }
                    }
                }
            }
            let navController = UINavigationController(rootViewController: controller)
            navController.modalPresentationStyle = .formSheet
            present(navController, animated: true, completion: nil)

        // delete action
        case 5:
            let element = content[currentIndex.row]
            if element.type == "file" {
                let controller = DeleteElementViewController(element: content[currentIndex.row])
                controller.onFinish = { [weak self] (success) in
                    if let vc = self {
                        DispatchQueue.main.async {
                            vc.dismiss(animated: true, completion: nil) // dismiss DeleteFileViewController
                            if success {
                                vc.content.remove(at: vc.currentIndex.row)
                                vc.tableView.deleteRows(at: [vc.currentIndex], with: .left)
                            }
                            else {
                                vc.getFolderContent()
                            }
                        }
                    }
                }
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
        // folder info
        case 6:
            let controller = FolderInfoViewController(element: content[currentIndex.row])
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
        //
        default:
            return
        }
    }
}
