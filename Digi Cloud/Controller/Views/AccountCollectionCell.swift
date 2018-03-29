//
//  AccountCell.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 09/01/17.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import UIKit

final class AccountCollectionCell: UICollectionViewCell {

    // MARK: - Properties

    let profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        return imageView
    }()

    let accountNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.fontHelveticaNeueMedium(size: 14)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    // MARK: - Overridden Methods and Properties

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Helper Functions

    private func setupViews() {

        addSubview(profileImage)
        addSubview(accountNameLabel)

        NSLayoutConstraint.activate([
            profileImage.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.4),
            profileImage.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            profileImage.topAnchor.constraint(equalTo: self.topAnchor),
            profileImage.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.4),
            accountNameLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.0),
            accountNameLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            accountNameLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 5)
        ])
    }
}
