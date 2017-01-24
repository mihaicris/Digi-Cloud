//
//  AccountTableViewCell.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 10/01/17.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import UIKit

class AccountTableViewCell: UITableViewCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        imageView?.layer.cornerRadius = 5
        imageView?.layer.masksToBounds = true
        imageView?.contentMode = .scaleAspectFit
        textLabel?.font = UIFont.systemFont(ofSize: 14)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var account: Account? {
        didSet {
            if let accountName = account?.account {
                self.textLabel?.text = accountName
                let cache = Cache()
                if let data = cache.load(type: .profile, key: accountName) {
                    self.imageView?.image = UIImage(data: data)
                } else {
                    self.imageView?.image = #imageLiteral(resourceName: "DefaultAccountProfileImage")
                }
            }
        }
    }
}
