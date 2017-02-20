//
//  BaseListCell.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 20/10/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class BaseListCell: UITableViewCell {

    // MARK: - Properties

    var hasButton: Bool = false {
        didSet {
            setupActionsButton()
        }
    }
    var isSender: Bool = false

    weak var delegate: BaseListCellDelegate?

    lazy var actionsButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.setTitle("⋯", for: .normal)
        button.tag = 1
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.contentHorizontalAlignment = .center
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.addTarget(self, action: #selector(handleAction), for: .touchUpInside)
        return button
    }()

    var labelRightMarginConstraint: NSLayoutConstraint?

    // MARK: - Initializers and Deinitializers

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overridden Methods and Properties

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupViews()
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        actionsButton.alpha = editing ? 0 : 1
        super.setEditing(editing, animated: animated)
    }

    // MARK: - Helper Functions

    func setupViews() {
        self.clipsToBounds = true
    }

    func setupActionsButton() {
        if hasButton {
            contentView.addSubview(actionsButton)
            contentView.addConstraints(with: "H:[v0(64)]-(-4)-|", views: actionsButton)
            actionsButton.heightAnchor.constraint(equalToConstant: AppSettings.tableViewRowHeight * 0.95).isActive = true
            actionsButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
            labelRightMarginConstraint?.constant = -70
        } else {
            actionsButton.removeFromSuperview()
            labelRightMarginConstraint?.constant = -20
        }
        layoutSubviews()
    }

    @objc private func handleAction() {
        delegate?.showActionController(for: actionsButton)
    }
}
