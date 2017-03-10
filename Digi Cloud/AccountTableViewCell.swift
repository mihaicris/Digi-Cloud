//
//  AccountTableViewCell.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 10/01/17.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import UIKit

final class AccountTableViewCell: UITableViewCell {

    var account: Account? {
        didSet {
            guard let username = account?.username, let name = UserDefaults.standard.string(forKey: username) else {
                return
            }
            self.accountNameLabel.text = name
            self.accountUsernameLabel.text = username
            let cache = Cache()
            if let data = cache.load(type: .profile, key: username) {
                self.profileImageView.image = UIImage(data: data)
            } else {
                self.profileImageView.image = #imageLiteral(resourceName: "DefaultAccountProfileImage")
            }

        }
    }

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
        l.font = UIFont(name: "HelveticaNeue", size: 16)
        return l
    }()

    let accountUsernameLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont(name: "HelveticaNeue", size: 12)
        l.textColor = .darkGray
        return l
    }()

    private func setupViews() {

        contentView.addSubview(profileImageView)
        contentView.addSubview(accountNameLabel)
        contentView.addSubview(accountUsernameLabel)

        NSLayoutConstraint.activate([
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            profileImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.8),
            profileImageView.widthAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.8),
            accountNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -8),
            accountNameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8),
            accountNameLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20),
            accountUsernameLabel.topAnchor.constraint(equalTo: accountNameLabel.bottomAnchor, constant: 2),
            accountUsernameLabel.leftAnchor.constraint(equalTo: accountNameLabel.leftAnchor),
            accountUsernameLabel.rightAnchor.constraint(equalTo: accountNameLabel.rightAnchor)
        ])
    }

}
