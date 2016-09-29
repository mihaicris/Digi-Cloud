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

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let inset = bounds.insetBy(dx: 8, dy: 5)
        return inset
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
}
