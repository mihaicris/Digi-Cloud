//
//  CreateDirectoryViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 31/10/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

final class CreateDirectoryViewController: UITableViewController {

    // MARK: - Properties

    var onFinish: ((String) -> Void)?

    private var parentLocation: Location
    private var leftBarButton: UIBarButtonItem!
    fileprivate var rightBarButton: UIBarButtonItem!
    private var textField: UITextField!
    private var messageLabel: UILabel!

    // MARK: - Initializers and Deinitializers

    init(parentLocation: Location) {
        self.parentLocation = parentLocation
        super.init(style: .grouped)
        INITLog(self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit { DEINITLog(self) }

    // MARK: - Overridden Methods and Properties

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.textField.becomeFirstResponder()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none

        textField = UITextField()
        textField.placeholder = NSLocalizedString("Folder Name", comment: "")
        textField.clearButtonMode = .whileEditing
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .done
        textField.delegate = self
        textField.addTarget(self, action: #selector(handleTextFieldChange), for: .editingChanged)

        cell.contentView.addSubview(textField)
        cell.contentView.addConstraints(with: "H:|-20-[v0]-12-|", views: textField)
        cell.contentView.addConstraints(with: "V:|[v0]|", views: textField)

        return cell
    }

    // MARK: - Helper Functions

    private func setupViews() {

        messageLabel = {
            let label = UILabel()
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 14)
            label.textColor = .darkGray
            label.alpha = 0.0
            return label
        }()

        tableView.addSubview(messageLabel)
        tableView.addConstraints(with: "V:|-100-[v0]|", views: messageLabel)
        tableView.centerXAnchor.constraint(equalTo: messageLabel.centerXAnchor).isActive = true

        tableView.isScrollEnabled = false

        leftBarButton = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: ""),
                                        style: .plain,
                                        target: self,
                                        action: #selector(handleCancel))

        rightBarButton = UIBarButtonItem(title: NSLocalizedString("Create", comment: ""),
                                         style: .plain,
                                         target: self,
                                         action: #selector(handleCreateFolder))

        self.navigationItem.setLeftBarButton(leftBarButton, animated: false)
        self.navigationItem.setRightBarButton(rightBarButton, animated: false)

        // disable Create button
        rightBarButton.isEnabled = false

        self.title = NSLocalizedString("Create Directory", comment: "")
    }

    private func hasInvalidCharacters(name: String) -> Bool {
        let charset: Set<Character> = ["\\", "/", ":", "?", "<", ">", "\"", "|"]
        return !charset.isDisjoint(with: name.characters)
    }

    fileprivate func setMessage(onScreen: Bool, _ message: String? = nil) {
        if onScreen {
            self.messageLabel.text = message
        }
        UIView.animate(withDuration: onScreen ? 0.0 : 0.5, animations: {
            self.messageLabel.alpha = onScreen ? 1.0 : 0.0
        })
    }

    @objc private func handleCancel() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc fileprivate func handleCreateFolder() {

        textField.resignFirstResponder()

        // TODO: Show on screen spinner for create folder request

        // get the new name, space trimmed
        let charSet = CharacterSet.whitespaces
        guard let folderName = textField.text?.trimmingCharacters(in: charSet) else { return }

        // block a second Create request
        rightBarButton.isEnabled = false

        // network request for rename
        DigiClient.shared.createDirectory(at: self.parentLocation, named: folderName) { (statusCode, error) in
            // TODO: Stop spinner
            guard error == nil else {
                let title = NSLocalizedString("Error", comment: "")
                let message = NSLocalizedString("There was an error creating the directory.", comment: "")
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)

                DLog(object: error!.localizedDescription)

                return
            }
            if let code = statusCode {
                switch code {
                case 200:
                    // Rename successfully completed
                    self.dismiss(animated: true) {
                        self.onFinish?(folderName)
                    }
                case 400:
                    // Bad request ( Folder already exists, invalid file name?)
                    // show message and wait for a new name or cancel action
                    let message = NSLocalizedString("Folder already exists. Please choose a different name.", comment: "")
                    self.setMessage(onScreen: true, message)
                case 404:
                    // Not Found (Folder do not exists anymore), folder will refresh
                    let message = NSLocalizedString("File is no longer available. Directory will refresh.", comment: "")
                    self.leftBarButton.title = NSLocalizedString("Done", comment: "")
                    self.setMessage(onScreen: true, message)
                default :
                    let message = NSLocalizedString("Server replied with Status Code: ", comment: "")
                    self.setMessage(onScreen: true, message + String(code))
                }
            }
        }
    }

    @objc private func handleTextFieldChange() {
        if let name = textField.text {
            if name.isEmpty {
                self.rightBarButton.isEnabled = false
            } else if hasInvalidCharacters(name: name) {
                let message = NSLocalizedString("Characters \\ / : ? < > \" | are not allowed.", comment: "")
                setMessage(onScreen: true, message)
                self.rightBarButton.isEnabled = false
            } else {
                setMessage(onScreen: false)
                self.rightBarButton.isEnabled = true
            }
        }
    }
}

extension CreateDirectoryViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        setMessage(onScreen: false)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.rightBarButton.isEnabled {
            textField.resignFirstResponder()
            self.handleCreateFolder()
            return false
        }
        return false
    }
}
