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

    let locationNameLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.HelveticaNeue(size: 30)
        return l
    }()

    let ownerNameLabel: UILabelWithPadding = {
        let l = UILabelWithPadding(paddingTop: 2, paddingLeft: 7, paddingBottom: 2, paddingRight: 7)
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = UIColor.white
        l.backgroundColor = UIColor(red: 0.40, green: 0.43, blue: 0.98, alpha: 1.0)
        l.font = UIFont.HelveticaNeue(size: 12)
        l.layer.cornerRadius = 7
        l.clipsToBounds = true
        return l
    }()

    let ownerLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.HelveticaNeue(size: 16)
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
        l.font = UIFont.HelveticaNeue(size: 16)
        l.textColor = UIColor.defaultColor
        return l
    }()

    let statusLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "●"
        l.font = UIFont.HelveticaNeue(size: 22)
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
        ownerNameLabel.backgroundColor = UIColor(red: 0.40, green: 0.43, blue: 0.98, alpha: 1.0)
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        ownerNameLabel.backgroundColor = UIColor(red: 0.40, green: 0.43, blue: 0.98, alpha: 1.0)
    }

    // MARK: - Helper Functions

    private func setupViews() {
        contentView.addSubview(locationNameLabel)
        contentView.addSubview(statusLabel)

        NSLayoutConstraint.activate([
            locationNameLabel.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor),
            locationNameLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),

            statusLabel.centerYAnchor.constraint(equalTo: locationNameLabel.centerYAnchor),
            statusLabel.leftAnchor.constraint(equalTo:locationNameLabel.rightAnchor, constant: 10),
        ])

        if mount.type == "device" {
            contentView.addSubview(spaceUsedLabel)
            contentView.addSubview(spaceUsedValueLabel)

            NSLayoutConstraint.activate([

                spaceUsedLabel.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor),
                spaceUsedLabel.bottomAnchor.constraint(equalTo: locationNameLabel.bottomAnchor, constant: 25),

                spaceUsedValueLabel.firstBaselineAnchor.constraint(equalTo: spaceUsedLabel.firstBaselineAnchor),
                spaceUsedValueLabel.leftAnchor.constraint(equalTo: spaceUsedLabel.rightAnchor, constant: 10),
            ])
        }

        if mount.type == "import" || mount.type == "export" {

            contentView.addSubview(ownerLabel)
            contentView.addSubview(ownerNameLabel)

            NSLayoutConstraint.activate([
                ownerLabel.leftAnchor.constraint(equalTo: locationNameLabel.leftAnchor),
                ownerLabel.bottomAnchor.constraint(equalTo: locationNameLabel.bottomAnchor, constant: 25),

                ownerNameLabel.leftAnchor.constraint(equalTo: ownerLabel.rightAnchor, constant: 10),
                ownerNameLabel.centerYAnchor.constraint(equalTo: ownerLabel.centerYAnchor)
            ])
        }
    }
}
