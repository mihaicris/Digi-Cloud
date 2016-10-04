//
//  DirectoryCell.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 19/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class DirectoryCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
       
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var folderIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "FolderIcon"))
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    var folderNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
        label.lineBreakMode = .byTruncatingMiddle
        return label
    }()
    
    var actionButton: UIButton = {
        let button = UIButton()
        button.setTitle("...", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        button.contentHorizontalAlignment = .right
        button.setTitleColor(UIColor.darkGray, for: .normal)
        return button
    }()
    
    func setupViews() {
        
        separatorInset = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 0)
        
        contentView.addSubview(folderIcon)
        contentView.addSubview(folderNameLabel)
        contentView.addSubview(actionButton)
        
        // Horizontal contraints

        contentView.addConstraints(with: "H:|-10-[v0(28)]-10-[v1]-80-|", views: folderIcon, folderNameLabel)
        contentView.addConstraints(with: "H:[v0]-20-|", views: actionButton)
        
        // Vertical constraints
        
        folderIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -1).isActive = true
        folderNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 1).isActive = true
        actionButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        folderIcon.heightAnchor.constraint(equalToConstant: 28).isActive = true

    }
}
