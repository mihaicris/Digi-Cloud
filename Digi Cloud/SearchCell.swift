//
//  SearchCell.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 16/12/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

final class SearchCell: UITableViewCell {

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
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 15)
        label.lineBreakMode = .byTruncatingMiddle
        return label
    }()

    let nodeMountLabel: UILabelWithPadding = {
        let label = UILabelWithPadding(paddingTop: 1, paddingLeft: 7, paddingBottom: 2, paddingRight: 7)
        label.textColor = .darkGray
        label.font = UIFont(name: "HelveticaNeue", size: 11)
        label.textColor = .white
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    var nodePathLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .darkGray
        label.font = UIFont(name: "HelveticaNeue", size: 11)
        label.lineBreakMode = .byTruncatingMiddle
        return label
    }()

    var seeInDirectoryButton: UIButton = {
        let b = UIButton(type: UIButtonType.system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("\u{f115}", for: .normal)
        b.setTitleColor(UIColor.lightGray, for: .normal)
        b.titleLabel?.font = UIFont.fontAwesome(size: 18)
        return b
    }()

    var mountBackgroundColor: UIColor?

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
        self.nodeMountLabel.backgroundColor = mountBackgroundColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.nodeMountLabel.backgroundColor = mountBackgroundColor
    }

    // MARK: - Helper Functions

    private func setupViews() {
        contentView.addSubview(nodeIcon)
        contentView.addSubview(nodeNameLabel)
        contentView.addSubview(nodeMountLabel)
        contentView.addSubview(nodePathLabel)
        contentView.addSubview(seeInDirectoryButton)
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            nodeIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            nodeIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -1),
            nodeIcon.widthAnchor.constraint(equalToConstant: 26),
            nodeIcon.heightAnchor.constraint(equalToConstant: 26),

            nodeNameLabel.leadingAnchor.constraint(equalTo: nodeIcon.trailingAnchor, constant: 10),
            nodeNameLabel.trailingAnchor.constraint(lessThanOrEqualTo : layoutMarginsGuide.trailingAnchor, constant: -30),
            nodeNameLabel.topAnchor.constraint(equalTo: nodeIcon.topAnchor, constant: -7),

            nodeMountLabel.leadingAnchor.constraint(equalTo: nodeNameLabel.leadingAnchor),
            nodeMountLabel.topAnchor.constraint(equalTo: nodeNameLabel.bottomAnchor, constant: 2),

            nodePathLabel.leadingAnchor.constraint(equalTo: nodeMountLabel.trailingAnchor, constant: 2),
            nodePathLabel.trailingAnchor.constraint(lessThanOrEqualTo : layoutMarginsGuide.trailingAnchor, constant: -30),
            nodePathLabel.centerYAnchor.constraint(equalTo: nodeMountLabel.centerYAnchor),

            seeInDirectoryButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            seeInDirectoryButton.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor),
        ])
    }
}
