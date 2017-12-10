//
//  FileCell.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 19/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

final class FileCell: BaseListCell {

    // MARK: - Properties

    override var hasButton: Bool {
        didSet {
            super.setupActionsButton()
        }
    }

    // MARK: - Overridden Methods and Properties

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        iconImageView.image = #imageLiteral(resourceName: "file_icon")
        nodeNameLabel.font = UIFont.fontHelveticaNeue(size: 15)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Helper Functions

}
