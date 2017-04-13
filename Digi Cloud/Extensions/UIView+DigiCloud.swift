//
//  UIView+DigiCloud.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 05/01/17.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import UIKit.UIView

extension UIView {

    func addConstraints(with format: String, views: UIView...) {
        var viewsDictionary: [String: UIView] = [:]
        for view in views.enumerated() {
            let key = "v\(view.offset)"
            viewsDictionary[key] = view.element
            view.element.translatesAutoresizingMaskIntoConstraints = false
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format,
                                                      options: NSLayoutFormatOptions(),
                                                      metrics: nil,
                                                      views: viewsDictionary))
    }
}
