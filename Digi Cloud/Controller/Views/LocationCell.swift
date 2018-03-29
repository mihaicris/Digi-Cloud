//
//  LocationCell.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 18/11/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

final class LocationCell: UITableViewCell {

    // MARK: - Properties

    var mount: Mount! {

        didSet {
            if let mount = mount {

                locationNameLabel.text = mount.name
                ownerNameLabel.text = "\(mount.owner.firstName) \(mount.owner.lastName)"

                if mount.online {
                    statusLabel.textColor = UIColor(red: 0.0, green: 0.8, blue: 0.0, alpha: 1.0)
                } else {
                    statusLabel.textColor = UIColor.gray
                }

                if var spaceUsed = mount.spaceUsed, var spaceTotal = mount.spaceTotal {
                    spaceUsed /= 1024
                    spaceTotal /= 1024
                    spaceUsedValueLabel.text = "\(spaceUsed) / \(spaceTotal) GB"
                }

                setupViews()
            }
        }
    }

    let leftView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let locationNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.fontHelveticaNeue(size: 24)
        return label
    }()

    let ownerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("Owner", comment: "")
        label.font = UIFont.fontHelveticaNeue(size: 14)
        return label
    }()

    let ownerNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.fontHelveticaNeue(size: 14)
        label.textColor = UIColor.defaultColor
        return label
    }()

    let spaceUsedLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("Usage", comment: "")
        label.font = UIFont.fontHelveticaNeue(size: 14)
        return label
    }()

    let spaceUsedValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.fontHelveticaNeue(size: 14)
        label.textColor = UIColor.defaultColor
        return label
    }()

    let statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "●"
        label.font = UIFont.fontHelveticaNeue(size: 20)
        label.textColor = UIColor.white
        return label
    }()

    let desktopLabel: UILabelWithPadding = {
        let label = UILabelWithPadding(paddingTop: 4, paddingLeft: 5, paddingBottom: 4, paddingRight: 5)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.fontHelveticaNeueMedium(size: 12)
        label.text = "DESKTOP"
        label.layer.borderWidth = 0.6
        label.layer.borderColor = UIColor.black.cgColor
        label.layer.cornerRadius = 5
        return label
    }()

    // MARK: - Initializers and Deinitializers

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overridden Methods and Properties

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .blue
        accessoryType = .disclosureIndicator
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        setLeftViewBackgroundColor()
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        setLeftViewBackgroundColor()
    }

    // MARK: - Helper Functions

    private func setupViews() {
        contentView.addSubview(locationNameLabel)
        contentView.addSubview(statusLabel)
        contentView.addSubview(leftView)

        setLeftViewBackgroundColor()

        NSLayoutConstraint.activate([
            locationNameLabel.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor),
            locationNameLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),

            statusLabel.bottomAnchor.constraint(equalTo: locationNameLabel.bottomAnchor),
            statusLabel.leftAnchor.constraint(equalTo: locationNameLabel.rightAnchor, constant: 10),

            leftView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            leftView.topAnchor.constraint(equalTo: contentView.topAnchor),
            leftView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            leftView.widthAnchor.constraint(equalToConstant: 5)

        ])

        if mount.type == "device" {
            contentView.addSubview(spaceUsedLabel)
            contentView.addSubview(spaceUsedValueLabel)

            NSLayoutConstraint.activate([

                spaceUsedLabel.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor),
                spaceUsedLabel.bottomAnchor.constraint(equalTo: locationNameLabel.bottomAnchor, constant: 30),

                spaceUsedValueLabel.firstBaselineAnchor.constraint(equalTo: spaceUsedLabel.firstBaselineAnchor),
                spaceUsedValueLabel.leftAnchor.constraint(equalTo: spaceUsedLabel.rightAnchor, constant: 10)
            ])

            if mount.type == "device" && mount.origin == "desktop" {
                contentView.addSubview(desktopLabel)

                NSLayoutConstraint.activate([
                    desktopLabel.leftAnchor.constraint(equalTo: statusLabel.rightAnchor, constant: 10),
                    desktopLabel.centerYAnchor.constraint(equalTo: statusLabel.centerYAnchor)
                ])
            }

        }

        if mount.type == "import" || mount.type == "export" {

            contentView.addSubview(ownerLabel)
            contentView.addSubview(ownerNameLabel)

            NSLayoutConstraint.activate([
                ownerLabel.leftAnchor.constraint(equalTo: locationNameLabel.leftAnchor),
                ownerLabel.bottomAnchor.constraint(equalTo: locationNameLabel.bottomAnchor, constant: 30),

                ownerNameLabel.leftAnchor.constraint(equalTo: ownerLabel.rightAnchor, constant: 8),
                ownerNameLabel.centerYAnchor.constraint(equalTo: ownerLabel.centerYAnchor)
            ])
        }

    }

    private func setLeftViewBackgroundColor() {

        if mount.type == "device" {
            if mount.isPrimary {
                leftView.backgroundColor = UIColor(red: 0.8, green: 0.3, blue: 0.3, alpha: 1.0)
            } else {
                leftView.backgroundColor = UIColor(red: 0.7, green: 0.5, blue: 0.1, alpha: 1.0)
            }
        }

        if mount.type == "import" {
            leftView.backgroundColor = UIColor(red: 0.0, green: 0.6, blue: 0.0, alpha: 1.0)
        }

        if mount.type == "export" {
            leftView.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 1.0, alpha: 1.0)
        }
    }
}
