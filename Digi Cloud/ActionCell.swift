//
//  ActionCell.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 07/11/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class ActionCell: UITableViewCell {

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
        case .sendDownloadLink:
            addActionIcon(fontAwesomeCode: "\u{f0ee}")
        case .sendUploadLink:
            addActionIcon(fontAwesomeCode: "\u{f01a}")
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

    private func addActionIcon(fontAwesomeCode: Character) {
        let iconLabel: UILabel = {
            let l = UILabel()
            l.translatesAutoresizingMaskIntoConstraints = false
            l.attributedText = NSAttributedString(string: String(fontAwesomeCode),
                                                  attributes: [NSFontAttributeName: UIFont.fontAwesome(size: 16),
                                                               NSForegroundColorAttributeName: UIColor.lightGray])
            return l
        }()

        self.contentView.addSubview(iconLabel)

        NSLayoutConstraint.activate([
            iconLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            iconLabel.centerXAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.rightAnchor, constant: -4)
        ])
    }

    @objc private func handleSwitchValueChanged() {
        delegate?.onSwitchValueChanged(button: switchButton, value: switchButton.isOn)
    }
}
