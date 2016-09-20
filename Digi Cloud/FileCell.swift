//
//  FileCell.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 19/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class FileCell: UITableViewCell {

    @IBOutlet var fileNameLabel: UILabel!
    
    @IBOutlet var fileSizeLabel: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            self.contentView.backgroundColor = UIColor(colorLiteralRed: 37/255, green: 116/255, blue: 255/255, alpha: 1.0)
            self.fileNameLabel.textColor = UIColor.white
            self.fileSizeLabel.textColor = UIColor(colorLiteralRed: 190/255, green: 190/255, blue: 190/255, alpha: 1.0)
        } else {
            self.contentView.backgroundColor = nil
            self.fileNameLabel.textColor = UIColor.black
            self.fileSizeLabel.textColor = UIColor.darkGray
        }
    }
}
