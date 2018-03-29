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
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.fontHelveticaNeueMedium(size: 14)
        return label
    }()

    let pathLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.fontHelveticaNeue(size: 12)
        label.textColor = .darkGray
        return label
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
