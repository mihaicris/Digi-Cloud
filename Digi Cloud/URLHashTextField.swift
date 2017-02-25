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
        backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1.0)
        layer.cornerRadius = 6
        translatesAutoresizingMaskIntoConstraints = false
        autocapitalizationType = .none
        autocorrectionType = .no
        spellCheckingType = .no
        clearButtonMode = .whileEditing
        font = UIFont.boldSystemFont(ofSize: 16)
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let inset = bounds.insetBy(dx: 4, dy: 0)
        return inset
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }

}
