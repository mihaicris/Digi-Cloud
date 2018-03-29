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
        let imagView = UIImageView()
        imagView.translatesAutoresizingMaskIntoConstraints = false
        imagView.contentMode = .scaleAspectFit
        return imagView
    }()

    var nodeNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = .byTruncatingMiddle
        return label
    }()

    let nodeMountLabel: UILabelWithPadding = {
        let label = UILabelWithPadding(paddingTop: 1, paddingLeft: 7, paddingBottom: 2, paddingRight: 7)
        label.font = UIFont.fontHelveticaNeue(size: 11)
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
        label.font = UIFont.fontHelveticaNeue(size: 11)
        label.lineBreakMode = .byTruncatingMiddle
        return label
    }()

    var seeInFolderButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("\u{f115}", for: .normal)
        button.setTitleColor(UIColor.lightGray, for: .normal)
        button.titleLabel?.font = UIFont.fontAwesome(size: 18)
        return button
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
        contentView.addSubview(seeInFolderButton)
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            nodeIcon.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 15),
            nodeIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -1),
            nodeIcon.widthAnchor.constraint(equalToConstant: 26),
            nodeIcon.heightAnchor.constraint(equalToConstant: 26),

            nodeNameLabel.leftAnchor.constraint(equalTo: nodeIcon.rightAnchor, constant: 10),
            nodeNameLabel.rightAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.rightAnchor, constant: -30),
            nodeNameLabel.topAnchor.constraint(equalTo: nodeIcon.topAnchor, constant: -7),

            nodeMountLabel.leftAnchor.constraint(equalTo: nodeNameLabel.leftAnchor),
            nodeMountLabel.topAnchor.constraint(equalTo: nodeNameLabel.bottomAnchor, constant: 2),

            nodePathLabel.leftAnchor.constraint(equalTo: nodeMountLabel.rightAnchor, constant: 2),
            nodePathLabel.rightAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.rightAnchor, constant: -30),
            nodePathLabel.centerYAnchor.constraint(equalTo: nodeMountLabel.centerYAnchor),

            seeInFolderButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            seeInFolderButton.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor)
        ])
    }
}
