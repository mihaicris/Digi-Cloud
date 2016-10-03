//
//  CustomLabel.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 03/10/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class CustomLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        textColor = UIColor(colorLiteralRed: 184/255, green: 184/255, blue: 184/255, alpha: 1)
        font = UIFont(name: "Helvetica-Bold", size: 12)
        translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
