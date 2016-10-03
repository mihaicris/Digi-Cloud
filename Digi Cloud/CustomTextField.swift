//
//  CustomTextField.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 29/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

@IBDesignable
class CustomTextField: UITextField {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        textColor = UIColor(colorLiteralRed: 80/255, green: 80/255, blue: 80/255, alpha: 1.0)
        font = UIFont(name: "Helvetica-Bold", size: 16)
        backgroundColor = .white
        borderStyle = .roundedRect
        autocorrectionType = .no
        spellCheckingType = .no
        translatesAutoresizingMaskIntoConstraints = false
        contentVerticalAlignment = .bottom
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let inset = bounds.insetBy(dx: 8, dy: 5)
        return inset
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
}
