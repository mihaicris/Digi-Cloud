//
//  SearchCell.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 16/12/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class SearchCell: UITableViewCell {

    // MARK: - Properties
    var nodeIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    var nodeNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "HelveticaNeue", size: 15)
        label.lineBreakMode = .byTruncatingMiddle
        return label
    }()
    var nodeMountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "---- Mount ----"
        label.textAlignment = .center
        label.textColor = .white
        label.sizeToFit()
        label.font = UIFont(name: "HelveticaNeue", size: 11)
        label.alpha = 0.6
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        return label
    }()
    var nodePathLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .darkGray
        label.font = UIFont(name: "HelveticaNeue", size: 11)
        return label
    }()

    // MARK: - Initializers and Deinitializers

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overridden Methods and Properties

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if highlighted {
            self.nodeMountLabel.backgroundColor = UIColor(colorLiteralRed: 245/255, green: 145/255, blue: 5/255, alpha: 1.0)
        } else {
            self.nodeMountLabel.backgroundColor = UIColor(colorLiteralRed: 255/255, green: 155/255, blue: 15/255, alpha: 1.0)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            self.nodeMountLabel.backgroundColor = UIColor(colorLiteralRed: 245/255, green: 145/255, blue: 5/255, alpha: 1.0)
        } else {
            self.nodeMountLabel.backgroundColor = UIColor(colorLiteralRed: 255/255, green: 155/255, blue: 15/255, alpha: 1.0)
        }
    }

    // MARK: - Helper Functions

    func setupViews() {
        separatorInset = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 0)

        contentView.addSubview(nodeIcon)
        contentView.addSubview(nodeNameLabel)
        contentView.addSubview(nodeMountLabel)
        contentView.addSubview(nodePathLabel)

        contentView.addConstraints(with: "H:|-15-[v0(26)]-10-[v1]-30-|", views: nodeIcon, nodeNameLabel)

        nodeIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -1).isActive = true
        nodeIcon.heightAnchor.constraint(equalToConstant: 26)

        nodeNameLabel.topAnchor.constraint(equalTo: nodeIcon.topAnchor, constant: -5).isActive = true

        nodeMountLabel.leadingAnchor.constraint(equalTo: nodeIcon.trailingAnchor, constant: 10).isActive = true
        nodeMountLabel.topAnchor.constraint(equalTo: nodeNameLabel.bottomAnchor, constant: 2).isActive = true
        nodeMountLabel.widthAnchor.constraint(equalToConstant: nodeMountLabel.bounds.width).isActive = true
        nodeMountLabel.heightAnchor.constraint(equalToConstant: nodeMountLabel.bounds.height - 3).isActive = true

        nodePathLabel.leadingAnchor.constraint(equalTo: nodeMountLabel.trailingAnchor, constant: 3).isActive = true
        nodePathLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -30).isActive = true
        nodePathLabel.centerYAnchor.constraint(equalTo: nodeMountLabel.centerYAnchor).isActive = true
    }
}
