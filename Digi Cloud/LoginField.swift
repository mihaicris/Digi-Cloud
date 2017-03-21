//
//  LoginField.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 29/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

final class LoginField: UITextField {

    // MARK: - Properties

    private let label = UILabel()

    public var textFieldName: String? {
        get {
            return label.text
        }
        set(newVal) {
            label.text = newVal
        }
    }

    // MARK: - Initializers and Deinitializers

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overridden Methods and Properties

    override init(frame: CGRect) {
        super.init(frame: frame)

        textColor = UIColor(red: 80 / 255, green: 80 / 255, blue: 80 / 255, alpha: 1.0)
        font = UIFont.HelveticaNeueMedium(size: 16)
        backgroundColor = .white
        borderStyle = .roundedRect
        autocapitalizationType = .none
        autocorrectionType = .no
        keyboardType = .emailAddress
        spellCheckingType = .no
        translatesAutoresizingMaskIntoConstraints = false
        contentVerticalAlignment = .bottom
        clearButtonMode = .whileEditing

        label.textColor = UIColor(red: 184 / 255, green: 184 / 255, blue: 184 / 255, alpha: 1)
        label.font = UIFont.HelveticaNeueMedium(size: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = textFieldName ?? ""

        addSubview(label)

        label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8).isActive = true
        label.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let inset = bounds.insetBy(dx: 8, dy: 5)
        return inset
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
}
