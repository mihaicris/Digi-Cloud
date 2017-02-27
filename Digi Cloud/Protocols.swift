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

protocol ContentItem {
    var name: String { get }
    var location: Location { get }
    var type: String { get }
    var modified: TimeInterval { get }
    var size: Int64 { get }
    var contentType: String { get }
}

protocol NodeActionsViewControllerDelegate: class {
    func didSelectOption(action: ActionType)
}

protocol BaseListCellDelegate: class {
    func showActionController(for sourceView: UIView)
}

protocol DeleteViewControllerDelegate: class {
    func onConfirmDeletion()
}

protocol ActionCellDelegate: class {
    func onSwitchValueChanged(button: UISwitch, value: Bool)
}
