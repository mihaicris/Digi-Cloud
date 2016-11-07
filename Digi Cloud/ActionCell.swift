//
//  ActionCell.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 07/11/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class ActionCell: UITableViewCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    convenience init(title: String, tag: Int) {
        self.init()
        self.textLabel?.text = title
        self.textLabel?.font = UIFont.systemFont(ofSize: 18)
        self.textLabel?.textColor = tag == 5 ? .red : .defaultColor
        self.tag = tag
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
