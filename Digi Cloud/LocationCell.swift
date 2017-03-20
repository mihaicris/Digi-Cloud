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
    
    var mount: Mount? {
        didSet {
            if let mount = mount {
                if mount.online {
                    statusLabel.text = NSLocalizedString("ONLINE", comment: "")
                    statusLabel.sizeToFit()
                    statusLabel.backgroundColor = UIColor.green
                } else {
                    statusLabel.text = NSLocalizedString("OFFLINE", comment: "")
                    statusLabel.sizeToFit()
                    statusLabel.backgroundColor = UIColor.gray
                }
                ownerNameLabel.text = "\(mount.owner.firstName) \(mount.owner.lastName)"

                if var spaceUsed = mount.spaceUsed, var spaceTotal = mount.spaceTotal {
                    spaceUsed = spaceUsed / 1024
                    spaceTotal = spaceTotal / 1024
                    spaceUsedValueLabel.text = "\(spaceUsed) / \(spaceTotal)"
                }
            }
        }
    }

    let locationNameLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.HelveticaNeue(size: 30)
        return l
    }()

    let ownerLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = NSLocalizedString("OWNER", comment: "")
        l.font = UIFont.HelveticaNeue(size: 18)
        return l
    }()

    let ownerNameLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.HelveticaNeue(size: 18)
        return l
    }()

    let spaceUsedLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = NSLocalizedString("SPACE USED", comment: "")
        l.font = UIFont.HelveticaNeue(size: 18)
        return l
    }()

    let spaceUsedValueLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.HelveticaNeueLight(size: 23)
        return l
    }()

    let statusLabel: UILabelWithPadding = {
        let l = UILabelWithPadding(paddingTop: 1, paddingLeft: 5, paddingBottom: 1, paddingRight: 5)
        l.translatesAutoresizingMaskIntoConstraints = false
        l.layer.cornerRadius = 4
        l.clipsToBounds = true
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

        setupViews()
    }

    // MARK: - Helper Functions

    private func setupViews() {
        contentView.addSubview(locationNameLabel)
        contentView.addSubview(statusLabel)
        contentView.addSubview(ownerLabel)
        contentView.addSubview(ownerNameLabel)
        contentView.addSubview(spaceUsedLabel)
        contentView.addSubview(spaceUsedValueLabel)

        NSLayoutConstraint.activate([
            locationNameLabel.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor),
            locationNameLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),

            ownerLabel.leftAnchor.constraint(equalTo: locationNameLabel.leftAnchor),
            ownerLabel.topAnchor.constraint(equalTo: locationNameLabel.bottomAnchor, constant: 10),

            ownerNameLabel.leftAnchor.constraint(equalTo: ownerLabel.leftAnchor),
            ownerNameLabel.topAnchor.constraint(equalTo: ownerLabel.bottomAnchor),

            statusLabel.firstBaselineAnchor.constraint(equalTo: locationNameLabel.firstBaselineAnchor),
            statusLabel.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor),

            spaceUsedLabel.firstBaselineAnchor.constraint(equalTo: ownerLabel.firstBaselineAnchor),
            spaceUsedLabel.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor),

            spaceUsedValueLabel.topAnchor.constraint(equalTo: spaceUsedLabel.bottomAnchor),
            spaceUsedValueLabel.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor),

        ])




    }
}
