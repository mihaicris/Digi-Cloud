//
//  CustomLoginButton.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 03/10/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class LoginButton: UIButton {

    // MARK: - Initializers and Deinitializers

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overridden Methods and Properties

    override init(frame: CGRect) {
        super.init(frame: frame)

        titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        setTitleColor(.white, for: UIControlState.normal)
        backgroundColor = UIColor(colorLiteralRed: 76 / 255, green: 76 / 255, blue: 165 / 255, alpha: 1.0)
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 20
        layer.borderWidth = 0.9
        layer.borderColor = UIColor.white.cgColor
        layer.shadowRadius = 40
        layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        layer.shadowOpacity = 0.5
        layer.shadowColor = UIColor.white.cgColor
    }
}
