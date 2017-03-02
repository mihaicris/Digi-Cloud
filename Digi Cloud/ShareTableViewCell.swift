//
//  ShareTableViewCell.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 02/03/2017.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import UIKit

final class ShareTableViewCell: UITableViewCell {

    // MARK: - Properties

    var iconImageView: UIImageView = {
        let i = UIImageView()
        i.translatesAutoresizingMaskIntoConstraints = false
        i.contentMode = .scaleAspectFit
        i.image = #imageLiteral(resourceName: "download_link_image")
        return i
    }()

    var nameLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont(name: "HelveticaNeue", size: 16)
        l.textColor = UIColor.defaultColor
        l.lineBreakMode = .byTruncatingMiddle
        return l
    }()

    // MARK: - Initializers and Deinitializers

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overridden Methods and Properties

    // MARK: - Helper Functions

    private func setupViews() {

        contentView.addSubview(iconImageView)
        contentView.addSubview(nameLabel)

        NSLayoutConstraint.activate([
            // Dimentional constraints
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),

            // Horizontal constraints
            iconImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            nameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            // Vertical constraints
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -20),
            nameLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 20)
        ])

    }

}
