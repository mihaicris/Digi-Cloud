//
//  AccountTableViewCell.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 10/01/17.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import UIKit

class AccountTableViewCell: UITableViewCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.cornerRadius = 5
        iv.layer.masksToBounds = true
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    let accountNameLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 16)
        return l
    }()

    private func setupViews() {

        contentView.addSubview(profileImageView)
        contentView.addSubview(accountNameLabel)

        NSLayoutConstraint.activate([
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            profileImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.8),
            profileImageView.widthAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.8),
            accountNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -3),
            accountNameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 15),
            accountNameLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20)
        ])
    }

    var account: Account? {
        didSet {
            if let name = account?.account {
                self.accountNameLabel.text = name
                let cache = Cache()
                if let data = cache.load(type: .profile, key: name) {
                    self.profileImageView.image = UIImage(data: data)
                } else {
                    self.profileImageView.image = #imageLiteral(resourceName: "DefaultAccountProfileImage")
                }
            }
        }
    }
}
