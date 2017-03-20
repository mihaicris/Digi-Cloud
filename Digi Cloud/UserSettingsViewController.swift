//
//  UserSettingsViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 20/03/2017.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import UIKit

class UserSettingsViewController: UITableViewController, UITextFieldDelegate {

    lazy var firstNameTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.delegate = self
        return tf
    }()

    lazy var lastNameTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.delegate = self
        return tf
    }()

    var user: User

    init(user: User) {
        self.user = user
        super.init(style: .grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("User details", comment: "")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(handleSaveUserName))
    }

    @objc private func handleSaveUserName() {
        guard var firstName = firstNameTextField.text, var lastName = lastNameTextField.text else {
            return
        }

        firstName = firstName.trimmingCharacters(in: .whitespaces)
        lastName = lastName.trimmingCharacters(in: .whitespaces)

        if firstName.characters.count > 0 && lastName.characters.count > 0 {

            DigiClient.shared.updateUserInfo(firstName: firstName, lastName: lastName) { error in

                guard error == nil else {

                    var message: String

                    switch error! {

                    case NetworkingError.internetOffline(let msg), NetworkingError.requestTimedOut(let msg):
                        message = msg

                    default:
                        message = NSLocalizedString("There was an error while saving the user name.", comment: "")
                    }

                    let alertController = UIAlertController(title: NSLocalizedString("Error", comment: ""),
                                                            message: message,
                                                            preferredStyle: .alert)
                    let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil)
                    alertController.addAction(okAction)

                    self.present(alertController, animated: true, completion: nil)

                    return
                }

                let newUser = User(id: self.user.id, firstName: firstName, lastName: lastName, email: self.user.email, permissions: Permissions())
                AppSettings.persistUserInfo(user: newUser)

                _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return NSLocalizedString("User", comment: "")
        } else {
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none

        var currentTextField: UITextField

        if indexPath.row == 0 {
            currentTextField = firstNameTextField
            firstNameTextField.placeholder = NSLocalizedString("First Name", comment: "")
            firstNameTextField.text = user.firstName
        } else {
            currentTextField = lastNameTextField
            lastNameTextField.placeholder = NSLocalizedString("Last Name", comment: "")
            lastNameTextField.text = user.lastName
        }

        cell.contentView.addSubview(currentTextField)

        currentTextField.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
        currentTextField.leftAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.leftAnchor).isActive = true
        currentTextField.rightAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.rightAnchor).isActive = true

        return cell
    }
}
