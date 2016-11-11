//
//  DirectoryCell.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 19/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class DirectoryCell: BaseListCell {

    var folderIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "FolderIcon"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    var folderNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
        label.lineBreakMode = .byTruncatingMiddle
        return label
    }()

    override func setupViews() {

        separatorInset = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 0)

        contentView.addSubview(folderIcon)
        contentView.addSubview(folderNameLabel)

        // Horizontal constraints

        contentView.addConstraints(with: "H:|-15-[v0(26)]-10-[v1]-80-|", views: folderIcon, folderNameLabel)
        contentView.addConstraints(with: "V:[v0(26)]", views: folderIcon)

        // Vertical constraints

        folderIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -1).isActive = true
        folderNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 1).isActive = true

        super.setupViews()
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if highlighted {
            contentView.backgroundColor = UIColor(colorLiteralRed: 37/255, green: 116/255, blue: 255/255, alpha: 1.0)
            folderNameLabel.textColor = UIColor.white
            actionButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        } else {
            contentView.backgroundColor = nil
            folderNameLabel.textColor = UIColor.black
            actionButton.setTitleColor(UIColor.darkGray, for: UIControlState.normal)
        }
    }
}
