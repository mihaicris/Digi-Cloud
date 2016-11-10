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

    /// Init an ActionCell
    ///
    /// - Parameters:
    ///   - title: textLabel text
    ///   - tag: tag of the cells view
    ///   - hasSwitch: if true, the cell will contain a UISwitch on the right side

    init(title: String, tag: Int, hasSwitch: Bool = false) {
        super.init(style: UITableViewCellStyle.default, reuseIdentifier: nil)
        self.textLabel?.text = title
        self.textLabel?.font = UIFont.systemFont(ofSize: 18)
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
        if hasSwitch {
            addSwitch()
        }
    }

    /// Helper function to add the UISwitch to the cell
    private func addSwitch() {
        let switchButton = UISwitch()

        /// TODO: - Get this parameter from UserDefaults
        switchButton.isOn = true

        contentView.addSubview(switchButton)
        contentView.addConstraints(with: "H:[v0]-10-|", views: switchButton)
        switchButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
