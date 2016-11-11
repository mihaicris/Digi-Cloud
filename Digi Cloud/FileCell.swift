//
//  FileCell.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 19/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class FileCell: BaseListCell {

    var fileIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "FileIcon"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    var fileNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "HelveticaNeue", size: 15)
        label.lineBreakMode = .byTruncatingMiddle
        return label
    }()

    var fileSizeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "HelveticaNeue", size: 11)
        label.textColor = UIColor.darkGray
        return label
    }()

    override func setupViews() {

        super.setupViews()

        separatorInset = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 0)

        contentView.addSubview(fileIcon)
        contentView.addSubview(fileNameLabel)
        contentView.addSubview(fileSizeLabel)

        contentView.addConstraints(with: "H:|-15-[v0(26)]-10-[v1]-80-|", views: fileIcon, fileNameLabel)
        contentView.addConstraints(with: "H:[v0]-10-[v1]", views: fileIcon, fileSizeLabel)
        contentView.addConstraints(with: "V:[v0(26)]", views: fileIcon)
        contentView.addConstraints(with: "V:[v0]-2-[v1]", views: fileNameLabel, fileSizeLabel)

        fileIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -1).isActive = true
        fileNameLabel.topAnchor.constraint(equalTo: fileIcon.topAnchor, constant: -3).isActive = true
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if highlighted {
            contentView.backgroundColor = UIColor(colorLiteralRed: 37/255, green: 116/255, blue: 255/255, alpha: 1.0)
            fileNameLabel.textColor = UIColor.white
            fileSizeLabel.textColor = UIColor(colorLiteralRed: 200/255, green: 200/255, blue: 200/255, alpha: 1.0)
            actionButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        } else {
            contentView.backgroundColor = nil
            fileNameLabel.textColor = UIColor.black
            fileSizeLabel.textColor = UIColor.darkGray
            actionButton.setTitleColor(UIColor.darkGray, for: UIControlState.normal)
        }
    }
}
