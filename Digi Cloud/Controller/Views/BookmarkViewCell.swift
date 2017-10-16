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

    let bookmarkNameLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.HelveticaNeueMedium(size: 14)
        return l
    }()

    let pathLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.HelveticaNeue(size: 12)
        l.textColor = .darkGray
        return l
    }()

    private func setupViews() {
        contentView.addSubview(bookmarkNameLabel)
        contentView.addSubview(pathLabel)
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            bookmarkNameLabel.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor),
            bookmarkNameLabel.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor),
            bookmarkNameLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            pathLabel.leftAnchor.constraint(equalTo: bookmarkNameLabel.leftAnchor),
            pathLabel.rightAnchor.constraint(equalTo: bookmarkNameLabel.rightAnchor),
            pathLabel.topAnchor.constraint(equalTo: bookmarkNameLabel.bottomAnchor, constant: 2)
        ])
    }
}
