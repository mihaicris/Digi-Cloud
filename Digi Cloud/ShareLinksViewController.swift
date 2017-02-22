//
//  ShareLinkViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 21/02/2017.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import UIKit

class ShareLinkViewController: UIViewController {

    // MARK: - Properties

    var onFinish: (() -> Void)?

    var link: Link?
    var receiver: Receiver?

    let linkType: LinkType
    let node: Node

    // MARK: - Initializers and Deinitializers

    init(node: Node, linkType: LinkType) {

        self.node = node
        self.linkType = linkType
        self.link = node.link
        self.receiver = node.receiver

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overridden Methods and Properties

    override func viewDidLoad() {
        setupNavigationItem()
    }

    // MARK: - Helper Functions
    private func setupNavigationItem() {

        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))

        navigationItem.setRightBarButton(cancelButton, animated: false)
    }

    @objc private func handleCancel() {
        onFinish?()
    }
}
