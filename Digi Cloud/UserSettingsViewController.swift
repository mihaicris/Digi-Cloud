//
//  UserSettingsViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 20/03/2017.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import UIKit

class UserSettingsViewController: UITableViewController,
                                  UITextFieldDelegate,
                                  UIImagePickerControllerDelegate,
                                  UINavigationControllerDelegate {

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

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Save", comment: ""),
                                                            style: .plain, target: self, action: #selector(handleSaveUserName))
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
        return 2
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return NSLocalizedString("User", comment: "")
        } else {
            return NSLocalizedString("Profile picture", comment: "")
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else {
            return 2
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none

        if indexPath.section == 0 {

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
        } else if indexPath.row == 1 {
            cell.textLabel?.text = NSLocalizedString("Make picture", comment: "")
            cell.textLabel?.textColor = .defaultColor
        } else {
            cell.textLabel?.text = NSLocalizedString("Select picture", comment: "")
            cell.textLabel?.textColor = .defaultColor
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {

            let controller = UIImagePickerController()
            controller.delegate = self
            controller.allowsEditing = true

            if indexPath.row == 0 {
                controller.sourceType = .photoLibrary

            } else {
                controller.sourceType = .camera
                controller.cameraCaptureMode = .photo
                controller.cameraDevice = .front
                controller.showsCameraControls = true

            }

            present(controller, animated: true, completion: nil)

        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {

        var selectedImage: UIImage?

        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
                selectedImage = image
        }

        if let selectedImage = selectedImage {
            if let data = UIImagePNGRepresentation(selectedImage) {

                self.dismiss(animated: true) {
                    DigiClient.shared.setUserProfileImage(data) { error in

                        guard error == nil else {

                            return
                        }

                        let cache = Cache()
                        let key = self.user.id + ".png"

                        cache.save(type: .profile, data: data, for: key)
                        _ = self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
}
