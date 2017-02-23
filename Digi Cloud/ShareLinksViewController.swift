//
//  ShareLinkViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 21/02/2017.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import UIKit

class ShareLinkViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Properties

    var onFinish: (() -> Void)?

    var link: Link?
    var receiver: Receiver?

    let linkType: LinkType
    let node: Node

    private lazy var tableView: UITableView = {
        let frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        let t = UITableView(frame: frame, style: .grouped)
        t.translatesAutoresizingMaskIntoConstraints = false
        t.delegate = self
        t.dataSource = self
        return t
    }()

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
        setupViews()
        setupNavigationItems()
        setupToolBarItems()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        let headerTitle: String

        switch section {
        case 0:
            headerTitle = NSLocalizedString("LINK", comment: "")
        case 1:
            headerTitle = NSLocalizedString("PASSWORD", comment: "")
        case 2:
            headerTitle = NSLocalizedString("VALIDITY", comment: "")
        default:
            fatalError("Wrong section index")
        }

        return headerTitle
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        return cell
    }

    // MARK: - Helper Functions

    private func setupViews() {

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])

        setupTableViewHeaderView()
    }

    private func setupTableViewHeaderView() {

        let frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 117)
        let headerView = UIView(frame: frame)

        let headerImageView: UIImageView = {
            let iv = UIImageView(image: #imageLiteral(resourceName: "download_link_image"))
            iv.translatesAutoresizingMaskIntoConstraints = false
            return iv
        }()

        headerView.addSubview(headerImageView)

        NSLayoutConstraint.activate([
            headerImageView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            headerImageView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor)
        ])

        tableView.tableHeaderView = headerView
    }

    private func setupNavigationItems() {
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDone))
        navigationItem.setRightBarButton(doneButton, animated: false)
    }

    private func setupToolBarItems() {
        let sendButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(handleSend))
        let flexibleButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)

        let deleteButton: UIBarButtonItem = {
            let v = UIButton(type: UIButtonType.system)
            v.setTitle(NSLocalizedString("Delete Link", comment: ""), for: .normal)
            v.addTarget(self, action: #selector(handleDelete), for: .touchUpInside)
            v.setTitleColor(UIColor(white: 0.8, alpha: 1), for: .disabled)
            v.setTitleColor(.red, for: .normal)
            v.titleLabel?.font = UIFont.systemFont(ofSize: 18)
            v.sizeToFit()
            let b = UIBarButtonItem(customView: v)
            return b
        }()

        self.navigationController?.isToolbarHidden = false
        self.setToolbarItems([deleteButton, flexibleButton, sendButton], animated: false)

    }

    @objc private func handleDone() {
        onFinish?()
    }

    @objc private func handleSend() {}

    @objc private func handleDelete() {}

}
