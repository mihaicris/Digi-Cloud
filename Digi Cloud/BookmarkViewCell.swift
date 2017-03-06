//
//  BookmarkViewCell.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 06/03/2017.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import UIKit

final class BookmarkViewCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let nameLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont(name: "HelveticaNeue", size: 16)
        return l
    }()

    let pathLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont(name: "HelveticaNeue", size: 12)
        l.textColor = .darkGray
        return l
    }()

    private func setupViews() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(pathLabel)
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            nameLabel.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor),
            nameLabel.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor),
            nameLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            pathLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor),
            pathLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2)
        ])
    }
}
