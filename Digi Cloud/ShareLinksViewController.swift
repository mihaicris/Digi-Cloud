//
//  ShareLinkViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 21/02/2017.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import UIKit

class ShareLinkViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

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

    private lazy var hashTextField: URLHashTextField = {
        let tv = URLHashTextField()
        tv.delegate = self
        return tv
    }()

    private let enablePasswordSwitch: UISwitch = {
        let sw = UISwitch()
        sw.translatesAutoresizingMaskIntoConstraints = false
        sw.isOn = true
        sw.addTarget(self, action: #selector(handleEnablePassword(_:)), for: .valueChanged)
        return sw
    }()

    private let passwordLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "475939"
        l.font = UIFont.systemFont(ofSize: 16)
        return l
    }()

    private lazy var passwordResetButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(#imageLiteral(resourceName: "Refresh_icon"), for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(handleResetPassword), for: .touchUpInside)
        return b
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

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
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
        cell.selectionStyle = .none

        switch indexPath.section {
        case 0:
        // LINK

            let baseLinkLabel: UILabelWithPadding = {
                let l = UILabelWithPadding(paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
                l.textAlignment = .left
                l.text = "http://s.go.ro/ "
                l.translatesAutoresizingMaskIntoConstraints = false
                l.font = UIFont.systemFont(ofSize: 16)
                return l
            }()

            cell.contentView.addSubview(baseLinkLabel)
            cell.contentView.addSubview(hashTextField)

            NSLayoutConstraint.activate([
                baseLinkLabel.leadingAnchor.constraint(equalTo: cell.layoutMarginsGuide.leadingAnchor),
                baseLinkLabel.trailingAnchor.constraint(equalTo: hashTextField.leadingAnchor),
                baseLinkLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                baseLinkLabel.heightAnchor.constraint(equalToConstant: 36),
                hashTextField.trailingAnchor.constraint(equalTo: cell.layoutMarginsGuide.trailingAnchor),
                hashTextField.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                hashTextField.heightAnchor.constraint(equalToConstant: 36)
            ])

        case 1:
        // PASSWORD

            cell.contentView.addSubview(passwordLabel)
            cell.contentView.addSubview(passwordResetButton)
            cell.contentView.addSubview(enablePasswordSwitch)

            NSLayoutConstraint.activate([
                passwordLabel.leadingAnchor.constraint(equalTo: cell.layoutMarginsGuide.leadingAnchor),
                passwordLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                passwordResetButton.leadingAnchor.constraint(equalTo: passwordLabel.trailingAnchor, constant: 30),
                passwordResetButton.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                enablePasswordSwitch.trailingAnchor.constraint(equalTo: cell.layoutMarginsGuide.trailingAnchor),
                enablePasswordSwitch.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
            ])

        case 2:
        // VALIDITY
            break
        default:
            fatalError("Wrong section index")
        }

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

        self.title = NSLocalizedString("Send Download Link", comment: "")
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

    @objc private func handleEnablePassword(_ sender: UISwitch) {}

    @objc private func handleResetPassword() {}

}
