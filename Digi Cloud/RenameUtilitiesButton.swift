//
//  RenameUtilitiesButton.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 01/02/2017.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import UIKit

class RenameUtilitiesButton: UIButton {

    // MARK: - Initializers and Deinitializers

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overridden Methods and Properties

    init(title: String, delegate: Any?, selector: Selector, tag: Int) {
        super.init(frame: CGRect.zero)
        self.tag = tag
        translatesAutoresizingMaskIntoConstraints = false
        contentHorizontalAlignment = .left
        layer.cornerRadius = 5
        backgroundColor = UIColor(white: 0.98, alpha: 1.0)
        setTitleColor(UIColor.defaultColor, for: .normal)
        setTitleColor(UIColor.defaultColor.withAlphaComponent(0.3), for: .highlighted)
        titleLabel?.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        contentEdgeInsets = UIEdgeInsets(top: 7, left: 10, bottom: 7, right: 10)
        setTitle(title, for: .normal)
        addTarget(delegate, action: selector, for: .touchUpInside)
        sizeToFit()
        titleLabel?.textColor = .black
    }

}
