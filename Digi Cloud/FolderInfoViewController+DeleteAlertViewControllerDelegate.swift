//
//  FolderInfoViewController+Delegate.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 09/11/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import Foundation

extension FolderInfoViewController: DeleteAlertViewControllerDelegate {

    func onConfirmDeletion() {

        // Dismiss DeleteAlertViewController
        dismiss(animated: true) {
            let elementPath = DigiClient.shared.currentPath.last! + self.element.name

            // network request for delete
            DigiClient.shared.delete(path: elementPath, name: self.element.name) { (statusCode, error) in

                // TODO: Stop spinner
                guard error == nil else {
                    // TODO Show message for error
                    print(error!.localizedDescription)
                    return
                }
                if let code = statusCode {
                    switch code {
                    case 200:
                        // Delete successfully completed
                        self.onFinish?(true, true)
                    case 400:
                        // TODO: Alert Bad Request
                        self.onFinish?(false, true)
                    case 404:
                        // File not found, folder will be refreshed
                        self.onFinish?(false, true)
                    default :
                        // TODO: Alert Status Code server
                        self.onFinish?(false, false)
                        return
                    }
                }
            }
        }
    }
}
