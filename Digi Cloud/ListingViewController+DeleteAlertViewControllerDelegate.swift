//
//  ListingViewController+DeleteAlertViewControllerDelegate.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 09/11/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import Foundation

extension ListingViewController: DeleteViewControllerDelegate {
    func onConfirmDeletion() {

        // Dismiss DeleteAlertViewController
        dismiss(animated: true) {
            let nodePath = self.location.path + self.content[self.currentIndex.row].name

            // network request for delete
            let deleteLocation = Location(mount: self.location.mount, path: nodePath)
            DigiClient.shared.deleteNode(location: deleteLocation) {

                (statusCode, error) in

                // TODO: Stop spinner
                guard error == nil else {
                    // TODO: Show message for error
                    print(error!.localizedDescription)
                    return
                }
                if let code = statusCode {
                    DispatchQueue.main.async {
                        switch code {
                        case 200:
                            self.content.remove(at: self.currentIndex.row)
                            self.tableView.deleteRows(at: [self.currentIndex], with: .left)
                        case 400:
                            self.getFolderContent()
                        case 404:
                            self.getFolderContent()
                        default :
                            break
                        }
                    }
                } else {
                    print("Error: could not obtain a statuscode")
                }
            }
        }
        
    }
}
