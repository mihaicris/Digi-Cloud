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

    private let linkType: LinkType
    private let node: Node
    private var linkId: String?

    private lazy var tableView: UITableView = {
        let frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        let t = UITableView(frame: frame, style: .grouped)
        t.translatesAutoresizingMaskIntoConstraints = false
        t.delegate = self
        t.dataSource = self
        return t
    }()

    let baseLinkLabel: UILabelWithPadding = {
        let l = UILabelWithPadding(paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        l.textAlignment = .left
        l.text = "http://s.go.ro/ "
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 16)
        return l
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
        l.font = UIFont.systemFont(ofSize: 16)
        return l
    }()

    private lazy var passwordResetButton: UIButton = {
        let b = UIButton(type: .system)
        b.tintColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        b.setImage(#imageLiteral(resourceName: "Refresh_icon").withRenderingMode(.alwaysTemplate), for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(handleResetPassword), for: .touchUpInside)
        return b
    }()

    private let validityLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 16)
        return l
    }()

    private let validityChangeButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle(NSLocalizedString("Change", comment: ""), for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        b.addTarget(self, action: #selector(handleChangeValidity), for: .touchUpInside)
        return b
    }()

    private lazy var validityButtonsStackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    // MARK: - Initializers and Deinitializers

    init(node: Node, linkType: LinkType) {

        self.node = node
        self.linkType = linkType

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

    override func viewWillAppear(_ animated: Bool) {
        requestLink()
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
                passwordResetButton.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 100),
                passwordResetButton.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                enablePasswordSwitch.trailingAnchor.constraint(equalTo: cell.layoutMarginsGuide.trailingAnchor),
                enablePasswordSwitch.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
            ])

        case 2:
            // VALIDITY

            cell.contentView.addSubview(validityLabel)
            cell.contentView.addSubview(validityChangeButton)

            NSLayoutConstraint.activate([
                validityLabel.leadingAnchor.constraint(equalTo: cell.layoutMarginsGuide.leadingAnchor),
                validityLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                validityChangeButton.trailingAnchor.constraint(equalTo: cell.layoutMarginsGuide.trailingAnchor),
                validityChangeButton.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
            ])

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

        if linkType == .download {
            self.title = NSLocalizedString("Send Download Link", comment: "")
        } else {
            self.title = NSLocalizedString("Send Upload Link", comment: "")
        }

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

    @objc private func handleSend() {
        // TODO: Implement
    }

    @objc private func handleDelete() {

        guard let linkId = self.linkId else {
            return
        }

        DigiClient.shared.deleteLink(node: self.node, type: self.linkType, linkId: linkId) { (error) in
            guard error == nil else {
                print("Error at deletion of the link.")
                return
            }

            self.onFinish?()
        }

    }

    @objc private func handleEnablePassword(_ sender: UISwitch) {

        guard let linkId = self.linkId else {
            return
        }

        if sender.isOn {
            self.handleResetPassword()
        } else {
            DigiClient.shared.removeLinkPassword(node: self.node, linkId: linkId, type: linkType) { (result, error) in
                guard error == nil else {
                    print(error!.localizedDescription)
                    return
                }

                self.process(result)
            }
        }
    }

    @objc private func handleResetPassword() {

        guard let linkId = self.linkId else {
            return
        }

        startSpinning()

        DigiClient.shared.setOrResetLinkPassword(node: self.node, linkId: linkId, type: linkType, completion: { (result, error) in

            self.stopSpinning()

            guard error == nil else {
                print(error!.localizedDescription)
                return
            }

            self.process(result)
        })
    }

    @objc private func handleChangeValidity() {
        // TODO: Implement
    }

    private func requestLink() {

        DigiClient.shared.getLink(for: self.node, type: self.linkType) { (result, error) in

            guard error == nil else {
                print(error!.localizedDescription)
                return
            }

            self.process(result)
        }
    }

    private func process(_ result: Any?) {
        if let link = result as? Link {
            updateInformation(linkId: link.id, host: link.host, hash: link.hash, password: link.password)
        } else if let receiver = result as? Receiver {
            updateInformation(linkId: receiver.id, host: receiver.host, hash: receiver.hash, password: receiver.password)
        } else {
            print("Error: No valid link received.")
        }
    }

    private func updateInformation(linkId: String, host: String, hash: String, password: String?) {

        self.linkId = linkId
        baseLinkLabel.text = String("\(host)/ ")
        hashTextField.text = hash

        if let password = password {
            passwordLabel.text = password
            enablePasswordSwitch.isOn = true
            passwordResetButton.alpha = 1.0
        } else {
            passwordLabel.text =  NSLocalizedString("The link is public", comment: "")
            enablePasswordSwitch.isOn = false
            passwordResetButton.alpha = 0.0
        }
    }

    private var animating: Bool = false

    private func startSpinning() {
        if(!animating) {
            animating = true
            spinWithOptions(options: .curveEaseIn)
        }
    }

    private func stopSpinning() {
        animating = false
    }

    func spinWithOptions(options: UIViewAnimationOptions) {
        UIView.animate(withDuration: 0.4, delay: 0.0, options: options, animations: { () -> Void in
            let val: CGFloat = CGFloat((M_PI / Double(2.0)))
            self.passwordResetButton.transform = self.passwordResetButton.transform.rotated(by: val)
        }) { (finished: Bool) -> Void in

            if(finished) {
                if(self.animating) {
                    self.spinWithOptions(options: .curveLinear)
                } else if (options != .curveEaseOut) {
                    self.spinWithOptions(options: .curveEaseOut)
                }
            }

        }
    }

}
