//
//  AddFolderViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 31/10/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class CreateFolderViewController: UITableViewController {

    var onFinish: ((_ folderName: String?) -> Void)?

    fileprivate var leftBarButton: UIBarButtonItem!
    fileprivate var rightBarButton: UIBarButtonItem!
    fileprivate var textField: UITextField!
    fileprivate var messageLabel: UILabel!

    init() {
        super.init(style: .grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none

        textField = UITextField()
        textField.placeholder = NSLocalizedString("Folder Name", comment: "Textfield placeholder")
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

    fileprivate func setupViews() {

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

        leftBarButton = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: "Button Title"),
                                        style: .plain,
                                       target: self,
                                       action: #selector(handleCancel))

        rightBarButton = UIBarButtonItem(title: NSLocalizedString("Create", comment: "Button Title"),
                                         style: .plain,
                                        target: self,
                                        action: #selector(handleCreateFolder))

        self.navigationItem.setLeftBarButton(leftBarButton, animated: false)
        self.navigationItem.setRightBarButton(rightBarButton, animated: false)

        // disable Create button
        rightBarButton.isEnabled = false

        self.title = NSLocalizedString("Create Folder", comment: "Window Title")
    }

    @objc fileprivate func handleCancel() {
        textField.resignFirstResponder()
        onFinish?(nil)
    }

    @objc fileprivate func handleCreateFolder() {

        textField.resignFirstResponder()

        // TODO: Show on screen spinner for create folder request

        // get the new name, space trimmed
        let charSet = CharacterSet(charactersIn: " ")
        guard let folderName = textField.text?.trimmingCharacters(in: charSet) else { return }

        //build the path of element to be renamed
        let rootPath = DigiClient.shared.currentPath.last!

        // block a second Create request
        rightBarButton.isEnabled = false

        // network request for rename
        DigiClient.shared.createFolder(path: rootPath, name: folderName) { (statusCode, error) in
            // TODO: Stop spinner
            guard error == nil else {
                // TODO: Show message for error
                print(error!.localizedDescription)
                return
            }
            if let code = statusCode {
                switch code {
                case 200:
                    // Rename successfully completed
                    self.onFinish?(folderName)
                case 400:
                    // Bad request ( Element already exists, invalid file name?)
                    // show message and wait for a new name or cancel action
                    let message = NSLocalizedString("Folder already exists. Please choose a different name", comment: "Error message")
                    self.setMessage(onScreen:true, message)
                case 404:
                    // Not Found (Element do not exists anymore), folder will refresh
                    let message = NSLocalizedString("File is no longer available. Folder will refresh", comment: "Error message")
                    DispatchQueue.main.async {
                        self.leftBarButton.title = NSLocalizedString("Done", comment: "Button Title")
                    }
                    self.setMessage(onScreen:true, message)
                default :
                    let message = NSLocalizedString("Server replied with Status Code: ", comment: "Error message")
                    self.setMessage(onScreen: true, message + String(code))
                }
            }
        }
    }

    @objc fileprivate func handleTextFieldChange() {
        if let name = textField.text {
            if name.isEmpty {
                setCreateFolderButton(false)
            } else if hasInvalidCharacters(name: name) {
                let message = NSLocalizedString("Characters \\ / : ? < > \" | are not allowed.", comment: "Error message")
                setMessage(onScreen: true, message)
                setCreateFolderButton(false)
            } else {
                setMessage(onScreen: false)
                setCreateFolderButton(true)
            }
        }
    }

    fileprivate func hasInvalidCharacters(name: String) -> Bool {
        let charset: Set<Character> = ["\\", "/", ":", "?", "<", ">", "\"", "|"]
        return !charset.isDisjoint(with: name.characters)
    }

    fileprivate func setCreateFolderButton(_ value: Bool) {
        self.rightBarButton.isEnabled = value

    }

    fileprivate func setMessage(onScreen: Bool, _ message: String? = nil) {
        DispatchQueue.main.async {
            if onScreen {
                self.messageLabel.text = message
            }
            UIView.animate(withDuration: onScreen ? 0.0 : 0.5, animations: {
                self.messageLabel.alpha = onScreen ? 1.0 : 0.0
            })
        }
    }

    #if DEBUG
    deinit {
        print("CreateFolderViewController deinit")
    }
    #endif
}

extension CreateFolderViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        setMessage(onScreen: false)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if rightBarButton.isEnabled {
            textField.resignFirstResponder()
            handleCreateFolder()
            return false
        }
        return false
    }
}
