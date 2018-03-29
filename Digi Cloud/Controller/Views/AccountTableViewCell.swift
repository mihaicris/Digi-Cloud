//
//  AccountTableViewCell.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 10/01/17.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import UIKit

final class AccountTableViewCell: UITableViewCell {

    var user: User? {
        didSet {
            guard let identifier = user?.identifier,
                  let firstName = user?.firstName,
                  let lastName = user?.lastName,
                  let username = user?.email else {
                return
            }
            self.accountNameLabel.text = "\(firstName) \(lastName)"
            self.accountUsernameLabel.text = username
            let cache = Cache()
            if let data = cache.load(type: .profile, key: "\(identifier).png") {
                self.profileImageView.image = UIImage(data: data, scale: UIScreen.main.scale)
            } else {
                self.profileImageView.image = #imageLiteral(resourceName: "default_profile_image")
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
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 5
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    let accountNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.fontHelveticaNeue(size: 16)
        return label
    }()

    let accountUsernameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.fontHelveticaNeue(size: 12)
        label.textColor = .darkGray
        return label
    }()

    private func setupViews() {

        contentView.addSubview(profileImageView)
        contentView.addSubview(accountNameLabel)
        contentView.addSubview(accountUsernameLabel)

        NSLayoutConstraint.activate([
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 15),
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
