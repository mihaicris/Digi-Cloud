//
//  ActionCell.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 07/11/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

final class ActionCell: UITableViewCell {

    // MARK: - Properties

    var switchButton: UISwitch!
    weak var delegate: ActionCellDelegate? {
        didSet {
            guard let delegate = delegate else { return }
            addSwitch(delegate: delegate)
        }
    }

    // MARK: - Initializers and Deinitializers

    /// Test
    ///
    /// - Parameters:
    ///   - title: test
    ///   - action: test
    init(title: String, action: ActionType) {
        super.init(style: UITableViewCellStyle.default, reuseIdentifier: nil)

        self.textLabel?.text = title
        self.textLabel?.font = UIFont.systemFont(ofSize: 16)

        self.tag = action.rawValue

        var color = UIColor.defaultColor

        switch action {
        case .noAction:
            color = .darkGray
        case .delete:
            color = .red
        default:
            break
        }
        self.textLabel?.textColor = color
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Helper Functions

    private func addSwitch(delegate: ActionCellDelegate) {
        switchButton = UISwitch()
        switchButton.addTarget(self, action: #selector(handleSwitchValueChanged), for: UIControlEvents.valueChanged)
        contentView.addSubview(switchButton)
        contentView.addConstraints(with: "H:[v0]-10-|", views: switchButton)
        switchButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }

    @objc private func handleSwitchValueChanged() {
        delegate?.onSwitchValueChanged(button: switchButton, value: switchButton.isOn)
    }
}
