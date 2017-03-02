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

    let locationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Helvetica", size: 30)
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

        setupViews()
    }

    // MARK: - Helper Functions

    private func setupViews() {
        contentView.addSubview(locationLabel)
        contentView.addConstraints(with: "H:|-15-[v0]|", views: locationLabel)
        contentView.addConstraints(with: "V:|[v0]|", views: locationLabel)
    }
}
