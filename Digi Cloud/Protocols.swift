//
//  Protocols.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 23/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

protocol Link {

    var id: String { get }
    var name: String { get }
    var path: String { get }
    var counter: Int { get }
    var url: String { get }
    var shortUrl: String { get }
    var hash: String { get }
    var host: String { get }
    var hasPassword: Bool { get }
    var password: String? { get }
    var validFrom: TimeInterval? { get }
    var validTo: TimeInterval? { get }
}

protocol NodeActionsViewControllerDelegate: class {
    func didSelectOption(action: ActionType)
}

protocol DeleteViewControllerDelegate: class {
    func onConfirmDeletion()
}

protocol ActionCellDelegate: class {
    func onSwitchValueChanged(button: UISwitch, value: Bool)
}
