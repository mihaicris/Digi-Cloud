//
//  UILabelWithPadding.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 19/12/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class UILabelWithPadding: UILabel {

    let paddingTop: CGFloat
    let paddingLeft: CGFloat
    let paddingBottom: CGFloat
    let paddingRight: CGFloat

    init(paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat) {
        self.paddingTop = paddingTop
        self.paddingLeft = paddingLeft
        self.paddingBottom = paddingBottom
        self.paddingRight = paddingRight
        super.init(frame: CGRect.zero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        let contentSize = super.intrinsicContentSize
        return CGSize(width: contentSize.width + paddingLeft + paddingRight,
                      height: contentSize.height + paddingTop + paddingBottom)
    }

    override func drawText(in rect: CGRect) {
        let insets: UIEdgeInsets = UIEdgeInsets(top: paddingTop, left: paddingLeft, bottom: paddingBottom, right: paddingRight)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }

}
