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

    var account: Account? {
        didSet {
            if let accountName = account?.account {
                accountLabel.text = accountName
            }
        }
    }

    let profileImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = #imageLiteral(resourceName: "AccountIcon")
        iv.tintColor = UIColor(red: 0.2, green: 0.4, blue: 0.2, alpha: 1.0)
        return iv
    }()

    let accountLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
        l.textColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0)
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
        addSubview(accountLabel)

        NSLayoutConstraint.activate([
            profileImage.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.4),
            profileImage.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            profileImage.topAnchor.constraint(equalTo: self.topAnchor),
            profileImage.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.4),
            accountLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.0),
            accountLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            accountLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 5)
        ])
    }
}
