//
//  Protocols.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 23/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import Foundation
import UIKit

protocol JSONDecodable {
    init?(JSON: Any)
}

protocol ActionViewControllerDelegate: class {
    func didSelectOption(tag: Int)
}

protocol BaseListCellDelegate: class {
    func showActionController(for sourceView: UIView)
}

protocol DeleteAlertViewControllerDelegate: class {
    func onConfirmDeletion()
}

protocol ActionCellDelegate: class {
    func onSwitchValueChanged(button: UISwitch, value: Bool)
}
