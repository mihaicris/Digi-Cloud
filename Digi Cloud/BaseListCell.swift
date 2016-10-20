//
//  BaseListControllerCellTableViewCell.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 20/10/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

protocol FilesTableViewControllerDelegate: class {
    func showActionController(for sourceView: UIView)
}

class BaseListCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    weak var delegate: FilesTableViewControllerDelegate?
    
    lazy var actionButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.setTitle("...", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.contentHorizontalAlignment = .center
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.addTarget(self, action: #selector(handleAction), for: .touchUpInside)
        return button
    }()
    
    @objc fileprivate func handleAction(){
        delegate?.showActionController(for: self.actionButton)
    }
    
    func setupViews() {
        contentView.addSubview(actionButton)
        contentView.addConstraints(with: "H:[v0(40)]-10-|", views: actionButton)
        actionButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
}
