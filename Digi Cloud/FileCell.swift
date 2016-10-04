//
//  FileCell.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 19/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class FileCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var fileIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "FileIcon"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    var fileNameLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    var fileSizeLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    var actionButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    func setupViews() {
        addSubview(fileNameLabel)
        addSubview(fileSizeLabel)
        addSubview(actionButton)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            contentView.backgroundColor = UIColor(colorLiteralRed: 37/255, green: 116/255, blue: 255/255, alpha: 1.0)
            fileNameLabel.textColor = UIColor.white
            fileSizeLabel.textColor = UIColor(colorLiteralRed: 200/255, green: 200/255, blue: 200/255, alpha: 1.0)
            separatorInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
            actionButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        } else {
            contentView.backgroundColor = nil
            fileNameLabel.textColor = UIColor.black
            fileSizeLabel.textColor = UIColor.darkGray
            separatorInset = UIEdgeInsets(top: 0.0, left: 53.0, bottom: 0.0, right: 0.0)
            actionButton.setTitleColor(UIColor.darkGray, for: UIControlState.normal)
        }
    }
}
