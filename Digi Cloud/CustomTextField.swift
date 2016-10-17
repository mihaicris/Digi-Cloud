//
//  CustomTextField.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 29/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {
    
    private let label = UILabel()
    
    public var textFieldName: String? {
        
        get {
            return label.text
        }
        set(newVal) {
            label.text = newVal
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        textColor = UIColor(colorLiteralRed: 80/255, green: 80/255, blue: 80/255, alpha: 1.0)
        font = UIFont(name: "Helvetica-Bold", size: 16)
        backgroundColor = .white
        borderStyle = .roundedRect
        autocapitalizationType = .none
        autocorrectionType = .no
        spellCheckingType = .no
        translatesAutoresizingMaskIntoConstraints = false
        contentVerticalAlignment = .bottom
        
        label.textColor = UIColor(colorLiteralRed: 184/255, green: 184/255, blue: 184/255, alpha: 1)
        label.font = UIFont(name: "Helvetica-Bold", size: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = textFieldName ?? ""
        
        addSubview(label)
        
        label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8).isActive = true
        label.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        
        
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
