//
//  FileCell.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 19/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class FileCell: BaseListCell {

    // MARK: - Properties

    override var hasButton: Bool {
        didSet {
            super.setupActionsButton()

            // In copy or move view controller it is not an active cell
            if !hasButton {
                isUserInteractionEnabled = false
                fileNameLabel.isEnabled = false
                fileDetailsLabel.isEnabled = false
            }
        }
    }

    var fileIcon: UIImageView = {
        let i = UIImageView(image: UIImage(named: "FileIcon"))
        i.translatesAutoresizingMaskIntoConstraints = false
        i.contentMode = .scaleAspectFit
        return i
    }()

    var fileNameLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont(name: "HelveticaNeue", size: 15)
        l.lineBreakMode = .byTruncatingMiddle
        return l
    }()

    var fileDetailsLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont(name: "HelveticaNeue", size: 11)
        return l
    }()

    var rightPaddingButtonConstraint: NSLayoutConstraint?

    // MARK: - Overridden Methods and Properties

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        if self.isEditing { return }

        if self.hasButton {
            if highlighted {
                contentView.backgroundColor = UIColor(colorLiteralRed: 37 / 255, green: 116 / 255, blue: 255 / 255, alpha: 1.0)
                fileNameLabel.textColor = .white
                fileDetailsLabel.textColor = UIColor.init(white: 0.8, alpha: 1)
                actionsButton.setTitleColor(.white, for: .normal)
            } else {
                contentView.backgroundColor = nil
                fileNameLabel.textColor = .black
                fileDetailsLabel.textColor = .darkGray
                actionsButton.setTitleColor(.darkGray, for: .normal)
            }
        }
    }

    // MARK: - Helper Functions

    override func setupViews() {

        separatorInset = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 0)

        contentView.addSubview(fileIcon)
        contentView.addSubview(fileNameLabel)
        contentView.addSubview(fileDetailsLabel)

        NSLayoutConstraint.activate([
            // Dimentional constraints
            fileIcon.widthAnchor.constraint(equalToConstant: 26),
            fileIcon.heightAnchor.constraint(equalToConstant: 26),

            // Horizontal constraints
            fileIcon.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 15),
            fileNameLabel.leftAnchor.constraint(equalTo: fileIcon.rightAnchor, constant: 10),
            fileDetailsLabel.leftAnchor.constraint(equalTo: fileNameLabel.leftAnchor),

            // Vertical constraints
            fileIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -1),
            fileNameLabel.topAnchor.constraint(equalTo: fileIcon.topAnchor, constant: -3),
            fileDetailsLabel.topAnchor.constraint(equalTo: fileNameLabel.bottomAnchor, constant: 2)
        ])

        labelRightMarginConstraint = fileNameLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        labelRightMarginConstraint?.isActive = true
    }

}
