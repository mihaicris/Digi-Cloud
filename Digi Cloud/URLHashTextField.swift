//
//  URLHashTextField.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 23/02/2017.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import UIKit

class URLHashTextField: UITextField {

    // MARK: - Initializers and Deinitializers

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overridden Methods and Properties

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1.0)
        layer.cornerRadius = 8
        translatesAutoresizingMaskIntoConstraints = false
        autocapitalizationType = .none
        autocorrectionType = .no
        spellCheckingType = .no
        keyboardType = .alphabet
        clearButtonMode = .whileEditing
        font = UIFont.boldSystemFont(ofSize: 16)
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {

        let padLeft: CGFloat = 5
        let padRight: CGFloat = 20

        let inset = CGRect(x: bounds.origin.x + padLeft,
                           y: bounds.origin.y,
                           width: bounds.width - padLeft - padRight,
                           height: bounds.height)
        return inset
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }

}
