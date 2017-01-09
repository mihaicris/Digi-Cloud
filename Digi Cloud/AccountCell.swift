//
//  AccountCell.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 09/01/17.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import UIKit

class AccountCell: UICollectionViewCell {

    var account: Account? {
        didSet {
            if let accountName = account?.account {
                accountLabel.text = accountName
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let profileImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.cornerRadius = 10
        iv.layer.borderColor = UIColor.white.cgColor
        iv.layer.borderWidth = 1
        iv.layer.masksToBounds = true
        iv.backgroundColor = UIColor.init(white: 1, alpha: 0.1)
        return iv
    }()

    let accountLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 14)
        l.textAlignment = .center
        l.numberOfLines = 2
        l.textColor = .white
        return l
    }()

    fileprivate func setupViews() {

        contentView.addSubview(profileImage)
        contentView.addSubview(accountLabel)

        NSLayoutConstraint.activate([
            profileImage.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8),
            profileImage.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImage.topAnchor.constraint(equalTo: contentView.topAnchor),
            profileImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
            accountLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1.0),
            accountLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            accountLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 5)
        ])
    }
}
