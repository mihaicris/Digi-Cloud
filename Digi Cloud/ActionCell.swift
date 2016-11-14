//
//  ActionCell.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 07/11/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit


/// Custom UITableViewCell. Initialization with title name and has optionally a UISwitch

class ActionCell: UITableViewCell {

    var switchButton: UISwitch!

    weak var delegate: ActionCellDelegate?

    /// Init an ActionCell
    ///
    /// - Parameters:
    ///   - title: textLabel text
    ///   - tag: tag of the cells view
    ///   - hasSwitch: if true, the cell will contain a UISwitch on the right side
    init(title: String, tag: Int, switchDelegate: AnyObject? = nil) {
        super.init(style: UITableViewCellStyle.default, reuseIdentifier: nil)
        self.textLabel?.text = title
        self.textLabel?.font = UIFont.systemFont(ofSize: 16)
        self.tag = tag
        let color: UIColor
        switch tag {
        case 0:
            color = .darkGray
        case 5:
            color = .red
        default:
            color = .defaultColor
        }
        self.textLabel?.textColor = color
        if let switchDelegate = switchDelegate as? ActionCellDelegate {
            addSwitch(delegate: switchDelegate)
        }
    }

    /// Helper function to add the UISwitch to the cell
    private func addSwitch(delegate: ActionCellDelegate) {
        switchButton = UISwitch()
        self.delegate = delegate
        switchButton.addTarget(self, action: #selector(handleSwitchValueChanged), for: UIControlEvents.valueChanged)
        contentView.addSubview(switchButton)
        contentView.addConstraints(with: "H:[v0]-10-|", views: switchButton)
        switchButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }

    @objc private func handleSwitchValueChanged() {
        delegate?.onSwitchValueChanged(button: switchButton, value: switchButton.isOn)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
