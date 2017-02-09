//
//  Protocols.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 23/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

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
