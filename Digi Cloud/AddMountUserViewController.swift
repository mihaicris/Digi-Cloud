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

    init(mount: Mount, user: User? = nil) {
        self.mount = mount

        if let user = user {
            isUserEdited = true
            self.user = user
        } else {
            isUserEdited = false
            self.user = User(id: "", name: "", email: "", permissions: Permissions())
        }

        var perm: [PermissionType] = [.write, .create_link, .create_reicever]

        // User can not manage a device type mount
        if mount.type != "device" {
            perm.append(.mount)
        }

        self.permissions = perm

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

            let permissionSwitch: UISwitch = {
                let sw = UISwitch()
                sw.translatesAutoresizingMaskIntoConstraints = false
                sw.tag = indexPath.row
                sw.addTarget(self, action: #selector(handleUpdateUserPermissions), for: .valueChanged)
                return sw
            }()

            cell.contentView.addSubview(permissionSwitch)

            NSLayoutConstraint.activate([
                permissionSwitch.rightAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.rightAnchor),
                permissionSwitch.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
            ])

            var permissionAction: String

            switch permissions[indexPath.row] {
            case .write:
                permissionAction = NSLocalizedString("Can modify", comment: "")
                permissionSwitch.isOn = user.permissions.write
            case .create_link:
                permissionAction = NSLocalizedString("Can create download links", comment: "")
                permissionSwitch.isOn = user.permissions.create_link
            case .create_reicever:
                permissionAction = NSLocalizedString("Can create receive links", comment: "")
                permissionSwitch.isOn = user.permissions.create_receiver
            case .mount:
                permissionAction = NSLocalizedString("Can manage share", comment: "")
                permissionSwitch.isOn = user.permissions.mount
            }

            cell.textLabel?.text = permissionAction
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
