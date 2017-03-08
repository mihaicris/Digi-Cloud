//
//  BaseListCell.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 20/10/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class BaseListCell: UITableViewCell {

    // MARK: - Properties

    var hasButton: Bool = false {
        didSet {
            setupActionsButton()
        }
    }

    var hasDownloadLink: Bool = false

    var actionsButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.setTitle("⋯", for: .normal)
        button.tag = 1
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.contentHorizontalAlignment = .center
        button.setTitleColor(UIColor.darkGray, for: .normal)
        return button
    }()

    var iconImageView: UIImageView = {
        let i = UIImageView()
        i.translatesAutoresizingMaskIntoConstraints = false
        i.contentMode = .scaleAspectFit
        return i
    }()

    var nameLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont(name: "HelveticaNeue", size: 15)
        l.lineBreakMode = .byTruncatingMiddle
        return l
    }()

    var detailsLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont(name: "HelveticaNeue", size: 11)
        return l
    }()

    var rightPaddingButtonConstraint: NSLayoutConstraint?

    // MARK: - Initializers and Deinitializers

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overridden Methods and Properties

    override func setEditing(_ editing: Bool, animated: Bool) {
        actionsButton.alpha = editing ? 0 : 1
        super.setEditing(editing, animated: animated)
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        if self.isEditing { return }

        if self.hasButton {
            if highlighted {
                contentView.backgroundColor = UIColor(colorLiteralRed: 37 / 255, green: 116 / 255, blue: 255 / 255, alpha: 1.0)
                nameLabel.textColor = .white
                detailsLabel.textColor = UIColor.init(white: 0.8, alpha: 1)
                actionsButton.setTitleColor(.white, for: .normal)
            } else {
                contentView.backgroundColor = nil
                nameLabel.textColor = .black
                detailsLabel.textColor = .darkGray
                actionsButton.setTitleColor(.darkGray, for: .normal)
            }
        }
    }

    // MARK: - Helper Functions

    func setupViews() {
        self.clipsToBounds = true

        separatorInset = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 0)

        contentView.addSubview(iconImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(detailsLabel)

        NSLayoutConstraint.activate([
            // Dimentional constraints
            iconImageView.widthAnchor.constraint(equalToConstant: 26),
            iconImageView.heightAnchor.constraint(equalToConstant: 26),

            // Horizontal constraints
            iconImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 15),
            nameLabel.leftAnchor.constraint(equalTo: iconImageView.rightAnchor, constant: 10),
            detailsLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor),

            // Vertical constraints
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -1),
            nameLabel.topAnchor.constraint(equalTo: iconImageView.topAnchor, constant: -3),
            detailsLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2)
            ])

        rightPaddingButtonConstraint = nameLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        rightPaddingButtonConstraint?.isActive = true
    }

    func setupActionsButton() {
        if hasButton {
            contentView.addSubview(actionsButton)
            contentView.addConstraints(with: "H:[v0(64)]-(-4)-|", views: actionsButton)
            actionsButton.heightAnchor.constraint(equalToConstant: AppSettings.tableViewRowHeight * 0.95).isActive = true
            actionsButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
            rightPaddingButtonConstraint?.constant = -70
        } else {
            actionsButton.removeFromSuperview()
            rightPaddingButtonConstraint?.constant = -20
        }
        layoutSubviews()
    }
}
