//
//  AddMountUserViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 12/03/2017.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import UIKit

class AddMountUserViewController: UITableViewController, UITextFieldDelegate {

    var onUpdatedUser: (() -> Void)?
    var user: User

    let isUserEdited: Bool

    enum PermissionType: Int {
        case write
        case create_link
        case create_reicever
        case mount
    }

    let permissions: [PermissionType]

    private let mount: Mount

    private lazy var saveMemberButton: UIButton = {
        let b = UIButton(type: UIButtonType.contactAdd)
        b.addTarget(self, action: #selector(handleSaveMember), for: .touchUpInside)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private lazy var usernameTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = NSLocalizedString("Email address", comment: "")
        tf.clearButtonMode = .whileEditing
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.returnKeyType = .send
        tf.delegate = self
        tf.addTarget(self, action: #selector(handleTextFieldChange), for: .editingChanged)
        return tf
    }()

    let writePermissionSwitch: UISwitch = {
        let sw = UISwitch()
        sw.translatesAutoresizingMaskIntoConstraints = false
        sw.tag = PermissionType.write.rawValue
        sw.addTarget(self, action: #selector(handleUpdateUserPermissions(_:)), for: .valueChanged)
        return sw
    }()

    let downloadLinkPermissionSwitch: UISwitch = {
        let sw = UISwitch()
        sw.translatesAutoresizingMaskIntoConstraints = false
        sw.tag = PermissionType.create_link.rawValue
        sw.addTarget(self, action: #selector(handleUpdateUserPermissions(_:)), for: .valueChanged)
        return sw
    }()

    let receiveLinkPermissionSwitch: UISwitch = {
        let sw = UISwitch()
        sw.translatesAutoresizingMaskIntoConstraints = false
        sw.tag = PermissionType.create_reicever.rawValue
        sw.addTarget(self, action: #selector(handleUpdateUserPermissions(_:)), for: .valueChanged)
        return sw
    }()

    let manageSharePermissionSwitch: UISwitch = {
        let sw = UISwitch()
        sw.translatesAutoresizingMaskIntoConstraints = false
        sw.tag = PermissionType.mount.rawValue
        sw.addTarget(self, action: #selector(handleUpdateUserPermissions(_:)), for: .valueChanged)
        return sw
    }()

    init(mount: Mount, user: User? = nil) {
        self.mount = mount

        if let user = user {
            isUserEdited = true
            self.user = user
        } else {
            isUserEdited = false
            self.user = User(id: "", name: "", email: "", permissions: Permissions())
        }

        self.permissions = [.write, .create_link, .create_reicever, .mount]

        super.init(style: .grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("Add member", comment: "")

        let saveMemberButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(handleSaveMember))

        navigationItem.rightBarButtonItem = saveMemberButton
        navigationController?.isToolbarHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.usernameTextField.becomeFirstResponder()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        navigationController?.isToolbarHidden = false
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : permissions.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? nil : NSLocalizedString("PERMISSIONS", comment: "")
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell()
        cell.selectionStyle = .none

        if indexPath.section == 0 {

            cell.selectionStyle = .none
            cell.contentView.addSubview(usernameTextField)

            if isUserEdited {
                usernameTextField.text = user.email
                usernameTextField.isUserInteractionEnabled = false
            }

            NSLayoutConstraint.activate([
                usernameTextField.leftAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.leftAnchor),
                usernameTextField.rightAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.rightAnchor),
                usernameTextField.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
                ])

            return cell

        } else {

            guard let permissionType = PermissionType(rawValue: indexPath.row) else {
                return cell
            }

            var aSwitch: UISwitch
            var permissionTitle: String

            switch permissionType {

            case .write:
                aSwitch = writePermissionSwitch
                aSwitch.isOn = user.permissions.write
                permissionTitle = NSLocalizedString("Can modify", comment: "")

            case .mount:
                aSwitch = manageSharePermissionSwitch
                aSwitch.isOn = user.permissions.write ? user.permissions.mount : false
                aSwitch.isEnabled = user.permissions.write ? true : false
                aSwitch.onTintColor = UIColor(red: 0.40, green: 0.43, blue: 0.98, alpha: 1.0)
                permissionTitle = NSLocalizedString("Can manage share", comment: "")

            case .create_link:
                aSwitch = downloadLinkPermissionSwitch
                aSwitch.isOn = user.permissions.write ? user.permissions.create_link : false
                aSwitch.isEnabled = user.permissions.write ? true : false
                permissionTitle = NSLocalizedString("Can create download links", comment: "")

            case .create_reicever:
                aSwitch = receiveLinkPermissionSwitch
                aSwitch.isOn = user.permissions.write ? user.permissions.create_receiver : false
                aSwitch.isEnabled = user.permissions.write ? true : false
                permissionTitle = NSLocalizedString("Can create receive links", comment: "")
            }

            cell.textLabel?.text = permissionTitle
            cell.contentView.addSubview(aSwitch)

            NSLayoutConstraint.activate([
                aSwitch.rightAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.rightAnchor),
                aSwitch.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
            ])

        }

        return cell
    }

    @objc private func handleUpdateUserPermissions(_ sender: UISwitch) {

        guard let permissionType = PermissionType(rawValue: sender.tag) else {
            return
        }

        switch permissionType {
        case .write:
            user.permissions.write = sender.isOn

            // Remove the orther permission if Write is OFF

            if sender.isOn {
                [downloadLinkPermissionSwitch, receiveLinkPermissionSwitch, manageSharePermissionSwitch].forEach {
                    $0.isEnabled = true
                }
            } else {
                [downloadLinkPermissionSwitch, receiveLinkPermissionSwitch, manageSharePermissionSwitch].forEach {
                    $0.isOn = false
                    $0.isEnabled = false
                }

                user.permissions.create_link = sender.isOn
                user.permissions.create_receiver = sender.isOn
                user.permissions.mount = sender.isOn
            }

        case .mount:
            user.permissions.mount = sender.isOn
        case .create_link:
            user.permissions.create_link = sender.isOn
        case .create_reicever:
            user.permissions.create_receiver = sender.isOn
        }
    }

    @objc private func handleSaveMember() {

        usernameTextField.resignFirstResponder()

        guard let username = usernameTextField.text, username.characters.count > 3 else {

            self.showAlert(message: NSLocalizedString("Please provide the email address of the Digi Storage user.", comment: ""))

            return
        }

        DigiClient.shared.updateMount(mount: mount, operation: .add, user: user) { user, error in

            guard error == nil else {

                self.showAlert(message: NSLocalizedString("The email address is not valid.", comment: ""))

                return
            }

            self.onUpdatedUser?()

        }
    }

    @objc private func handleTextFieldChange() {
        if let email = usernameTextField.text {
            self.user.email = email
        }
    }

    private func showAlert(message: String) {

        let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""),
                                      message: message,
                                      preferredStyle: UIAlertControllerStyle.alert)
        let actionOK = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(actionOK)
        self.present(alert, animated: false) {
            self.usernameTextField.becomeFirstResponder()
        }
    }

}
