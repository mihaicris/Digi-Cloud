//
//  RenameViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 21/10/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class RenameViewController: UITableViewController {

    // MARK: - Properties

    var onFinish: ((_ newName: String?, _ needRefresh: Bool) -> Void)?
    fileprivate var element: Element
    fileprivate var leftBarButton: UIBarButtonItem!
    fileprivate var rightBarButton: UIBarButtonItem!
    fileprivate var textField: UITextField!
    fileprivate var messageLabel: UILabel!
    fileprivate var needRefresh: Bool

    // MARK: - Initializers and Deinitializers

    init(element: Element) {
        self.element = element
        self.needRefresh = false
        super.init(style: .grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    #if DEBUG
    deinit {
        print("[DEINIT]: " + String(describing: type(of: self)))
    }
    #endif

    // MARK: - Overridden Methods and Properties

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
        positionCursor()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none

        let elementIcon: UIImageView = {
            let imageName = element.type == "dir" ? "FolderIcon" : "FileIcon"
            let imageView = UIImageView(image: UIImage(named: imageName))
            imageView.contentMode = .scaleAspectFit
            return imageView
        }()

        textField = UITextField()
        textField.text = element.name
        textField.clearButtonMode = .whileEditing
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .done
        textField.delegate = self
        textField.addTarget(self, action: #selector(handleTextFieldChange), for: .editingChanged)

        cell.contentView.addSubview(elementIcon)
        cell.contentView.addSubview(textField)
        cell.contentView.addConstraints(with: "H:|-20-[v0(26)]-12-[v1]-12-|", views: elementIcon, textField)
        cell.contentView.addConstraints(with: "V:[v0(26)]", views: elementIcon)
        cell.contentView.addConstraints(with: "V:|[v0]|", views: textField)
        elementIcon.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true

        return cell
    }

    // MARK: - Helper Functions

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

        leftBarButton = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: "Button Title"), style: .plain, target: self, action: #selector(handleCancel))
        rightBarButton = UIBarButtonItem(title: NSLocalizedString("Rename", comment: "Button Title"), style: .plain, target: self, action: #selector(handleRename))

        self.navigationItem.setLeftBarButton(leftBarButton, animated: false)
        self.navigationItem.setRightBarButton(rightBarButton, animated: false)

        // disable Rename button
        rightBarButton.isEnabled = false

        self.title = element.type == "dir" ?
            NSLocalizedString("Rename Folder", comment: "Window Title") :
            NSLocalizedString("Rename File", comment: "Window Title")
    }

    fileprivate func positionCursor() {
        guard let elementName = textField.text else { return }

        // file has an extension?
        let components = elementName.components(separatedBy: ".")
        guard components.count > 1 else { return }

        // yes, it has
        let elementExtension = components.last!

        // setting the cursor in the textField before the extension including the "."
        if let range = elementName.range(of: elementExtension) {
            let index: Int = elementName.distance(from: elementName.startIndex, to: range.lowerBound).advanced(by: -1)
            if let newPosition = textField.position(from: textField.beginningOfDocument, offset: index) {
                textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
            }
        }
    }

    fileprivate func hasInvalidCharacters(name: String) -> Bool {
        let charset: Set<Character> = ["\\", "/", ":", "?", "<", ">", "\"", "|"]
        return !charset.isDisjoint(with: name.characters)
    }

    fileprivate func setRenameButtonActive(_ value: Bool) {
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

    @objc fileprivate func handleCancel() {
        textField.resignFirstResponder()
        onFinish?(nil, needRefresh)
    }

    @objc fileprivate func handleRename() {

        textField.resignFirstResponder()

        // TODO: Show on screen spinner for rename request

        // get the new name, space trimmed
        let charSet = CharacterSet.whitespaces
        guard let name = textField.text?.trimmingCharacters(in: charSet) else { return }

        //build the path of element to be renamed
        let elementPath = DigiClient.shared.currentPath.last! + element.name

        // block a second Rename request
        setRenameButtonActive(false)

        // network request for rename
        DigiClient.shared.renameElement(path: elementPath, newName: name) { (statusCode, error) in
            // TODO: Stop spinner
            guard error == nil else {
                // TODO: Show message for error
                print("Error: \(error?.localizedDescription)")
                return
            }
            if let code = statusCode {
                switch code {
                case 200:
                    // Rename successfully completed
                    self.onFinish?(name, true)
                case 400:
                    // Bad request ( Element already exists, invalid file name?)
                    // show message and wait for a new name or cancel action
                    let message = NSLocalizedString("This name already exists. Please choose a different one.", comment: "Error message")
                    self.setMessage(onScreen: true, message)
                case 404:
                    // Not Found (Element do not exists anymore), folder will refresh
                    let message = NSLocalizedString("File is no longer available. Folder will refresh.", comment: "Error message")
                    self.needRefresh = true
                    DispatchQueue.main.async {
                        self.leftBarButton.title = NSLocalizedString("Done", comment: "Button Title")
                    }
                    self.setMessage(onScreen: true, message)
                default :
                    let message = NSLocalizedString("Server replied with Status Code: ", comment: "Error message")
                    self.needRefresh = true
                    self.setMessage(onScreen: true, message + String(code))
                }
            }
        }
    }

    @objc fileprivate func handleTextFieldChange() {
        if let newName = textField.text {
            if newName.isEmpty {
                setRenameButtonActive(false)
            } else if hasInvalidCharacters(name: newName) {
                let message = NSLocalizedString("Characters \\ / : ? < > \" | are not allowed.", comment: "Error Information")
                setMessage(onScreen: true, message)
                setRenameButtonActive(false)
            } else if element.name.lowercased() == newName.lowercased() {
                let message = NSLocalizedString("Name is the same.", comment: "Error Information")
                setMessage(onScreen: true, message)
                setRenameButtonActive(false)
            } else {
                setMessage(onScreen: false)
                setRenameButtonActive(true)
            }
        }
    }
}

extension RenameViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        setMessage(onScreen: false)
        positionCursor()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if rightBarButton.isEnabled {
            textField.resignFirstResponder()
            handleRename()
            return false
        }
        return false
    }
}

