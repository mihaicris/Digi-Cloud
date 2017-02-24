//
//  FileCell.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 19/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class FileCell: BaseListCell {

    // MARK: - Properties

    override var hasButton: Bool {
        didSet {
            super.setupActionsButton()

            // In copy or move view controller it is not an active cell
            if !hasButton {
                isUserInteractionEnabled = false
                nameLabel.isEnabled = false
                detailsLabel.isEnabled = false
            }
        }
    }

    // MARK: - Overridden Methods and Properties

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        iconImageView.image = UIImage(named: "FileIcon")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Helper Functions

}
