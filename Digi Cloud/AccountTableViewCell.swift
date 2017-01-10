//
//  AccountTableViewCell.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 10/01/17.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import UIKit

class AccountTableViewCell: UITableViewCell {

    var account: Account? {
        didSet {
            if let accountName = account?.account {
                self.textLabel?.text = accountName
            }
        }
    }
}
