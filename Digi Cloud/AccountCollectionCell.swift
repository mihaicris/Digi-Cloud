//
//  AccountCell.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 09/01/17.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import UIKit

class AccountCollectionCell: UICollectionViewCell {

    // MARK: - Properties

    let profileImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.cornerRadius = 10
        iv.layer.masksToBounds = true
        return iv
    }()

    let accountNameLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont(name: "HelveticaNeue-Medium", size: 14)
        l.textColor = UIColor.white
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
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

    fileprivate func setupViews() {

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
