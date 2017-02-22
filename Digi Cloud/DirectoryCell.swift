//
//  DirectoryCell.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 19/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class DirectoryCell: BaseListCell {

    // MARK: - Properties

    var isShared: Bool = false {
        didSet {
            setupSharedLabel()
        }
    }
    var isReceiver: Bool = false

    var directoryIcon: UIImageView = {
        let i = UIImageView(image: UIImage(named: "FolderIcon"))
        i.contentMode = .scaleAspectFit
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()

    var directoryNameLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
        l.lineBreakMode = .byTruncatingMiddle
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    var directoryDetailsLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont(name: "HelveticaNeue", size: 11)
        return l
    }()

    let sharedLabel: UILabelWithPadding = {
        let l = UILabelWithPadding(paddingTop: 2, paddingLeft: 20, paddingBottom: 2, paddingRight: 20)
        l.text = NSLocalizedString("SHARED", comment: "")
        l.textColor = .white
        l.font = UIFont.boldSystemFont(ofSize: 8)
        l.backgroundColor = UIColor.blue.withAlphaComponent(0.6)
        l.textAlignment = .center
        l.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 4)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // MARK: - Overridden Methods and Properties

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        if self.isEditing { return }

        if highlighted {
            contentView.backgroundColor = UIColor(colorLiteralRed: 37 / 255, green: 116 / 255, blue: 255 / 255, alpha: 1.0)
            directoryNameLabel.textColor = .white
            directoryDetailsLabel.textColor = UIColor.init(white: 0.8, alpha: 1)
            actionsButton.setTitleColor(.white, for: .normal)
            sharedLabel.alpha = 0
        } else {
            contentView.backgroundColor = nil
            directoryNameLabel.textColor = .black
            directoryDetailsLabel.textColor = .darkGray
            actionsButton.setTitleColor(.darkGray, for: .normal)
            sharedLabel.alpha = 1
        }
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        sharedLabel.alpha = editing ? 0: 1
        super.setEditing(editing, animated: animated)
    }

    // MARK: - Helper Functions

    override func setupViews() {

        super.setupViews()

        separatorInset = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 0)

        contentView.addSubview(directoryIcon)
        contentView.addSubview(directoryNameLabel)
        contentView.addSubview(directoryDetailsLabel)

        NSLayoutConstraint.activate([
            // Dimentional constraints
            directoryIcon.widthAnchor.constraint(equalToConstant: 26),
            directoryIcon.heightAnchor.constraint(equalToConstant: 26),

            // Horizontal constraints
            directoryIcon.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 15),
            directoryNameLabel.leftAnchor.constraint(equalTo: directoryIcon.rightAnchor, constant: 10),
            directoryDetailsLabel.leftAnchor.constraint(equalTo: directoryNameLabel.leftAnchor),

            // Vertical constraints
            directoryIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -1),
            directoryNameLabel.topAnchor.constraint(equalTo: directoryIcon.topAnchor, constant: -3),
            directoryDetailsLabel.topAnchor.constraint(equalTo: directoryNameLabel.bottomAnchor, constant: 2)
        ])

        labelRightMarginConstraint = directoryNameLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        labelRightMarginConstraint?.isActive = true
    }

    func setupSharedLabel() {

        if isShared {
            contentView.addSubview(sharedLabel)
            NSLayoutConstraint.activate([
                sharedLabel.centerXAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
                sharedLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -5)
            ])
        } else {
            sharedLabel.removeFromSuperview()
        }
    }
}
