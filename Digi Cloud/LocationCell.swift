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

            locationNameLabel.text = mount.name
            ownerNameLabel.text = "\(mount.owner.firstName) \(mount.owner.lastName)"

            if mount.online {
                statusLabel.textColor = UIColor(red: 0.0, green: 0.8, blue: 0.0, alpha: 1.0)
            } else {
                statusLabel.textColor = UIColor.gray
            }

            if var spaceUsed = mount.spaceUsed, var spaceTotal = mount.spaceTotal {
                spaceUsed = spaceUsed / 1024
                spaceTotal = spaceTotal / 1024
                spaceUsedValueLabel.text = "\(spaceUsed) / \(spaceTotal) GB"
            }

            setupViews()
        }
    }

    let leftView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    let locationNameLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.HelveticaNeue(size: 24)
        return l
    }()

    let ownerNameLabel: UILabelWithPadding = {
        let l = UILabelWithPadding(paddingTop: 2, paddingLeft: 7, paddingBottom: 2, paddingRight: 7)
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = UIColor.white
        l.font = UIFont.HelveticaNeue(size: 12)
        l.layer.cornerRadius = 6
        l.clipsToBounds = true
        return l
    }()

    let ownerLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.HelveticaNeue(size: 14)
        l.text = NSLocalizedString("Owned by", comment: "")
        return l
    }()

    let spaceUsedLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = NSLocalizedString("Usage", comment: "")
        l.font = UIFont.HelveticaNeue(size: 14)
        return l
    }()

    let spaceUsedValueLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.HelveticaNeue(size: 14)
        l.textColor = UIColor.defaultColor
        return l
    }()

    let statusLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "●"
        l.font = UIFont.HelveticaNeue(size: 20)
        l.textColor = UIColor.white
        return l
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
        setBackgroundColors()
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        setBackgroundColors()
    }

    // MARK: - Helper Functions

    private func setupViews() {
        contentView.addSubview(locationNameLabel)
        contentView.addSubview(statusLabel)
        contentView.addSubview(leftView)

        setBackgroundColors()

        NSLayoutConstraint.activate([
            locationNameLabel.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor),
            locationNameLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),

            statusLabel.centerYAnchor.constraint(equalTo: locationNameLabel.centerYAnchor),
            statusLabel.leftAnchor.constraint(equalTo:locationNameLabel.rightAnchor, constant: 10),

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
                spaceUsedValueLabel.leftAnchor.constraint(equalTo: spaceUsedLabel.rightAnchor, constant: 10),
            ])

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

    private func setBackgroundColors() {

        ownerNameLabel.backgroundColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)

        if mount.type == "device" && mount.isPrimary {
            leftView.backgroundColor = UIColor(red: 0.8, green: 0.3, blue: 0.3, alpha: 1.0)
        }

        if mount.type == "device" && !mount.isPrimary {
            leftView.backgroundColor = UIColor(red: 0.7, green: 0.5, blue: 0.1, alpha: 1.0)
        }

        if mount.type == "import" {
            leftView.backgroundColor = UIColor(red: 0.1, green: 0.8, blue: 0.1, alpha: 1.0)
        }

        if mount.type == "export" {
            leftView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.8, alpha: 1.0)
        }
    }
}
