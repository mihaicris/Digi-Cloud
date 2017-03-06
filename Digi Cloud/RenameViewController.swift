//
//  RenameViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 21/10/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

final class RenameViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Properties

    var onFinish: ((_ newName: String?, _ needRefresh: Bool) -> Void)?
    
    private var nodeLocation: Location
    private var node: Node
    
    private var leftBarButton: UIBarButtonItem!
    fileprivate var rightBarButton: UIBarButtonItem!
    private var textField: UITextField!

    private var messageLabel: UILabel = {
            let l = UILabel()
            l.translatesAutoresizingMaskIntoConstraints = false
            l.textAlignment = .center
            l.font = UIFont.systemFont(ofSize: 14)
            l.textColor = .darkGray
            l.alpha = 0.0
            return l
    }()

    private var needRefresh: Bool = false

    private lazy var tableView: UITableView = {
        let frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        let t = UITableView(frame: frame, style: .grouped)
        t.translatesAutoresizingMaskIntoConstraints = false
        t.delegate = self
        t.dataSource = self
        return t
    }()

    // MARK: - Initializers and Deinitializers

    init(nodeLocation: Location, node: Node) {
        self.nodeLocation = nodeLocation
        self.node = node
        super.init(nibName: nil, bundle: nil)
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

    // MARK: - TableView Delegate

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none

        let elementIcon: UIImageView = {
            let imageName = node.type == "dir" ? "FolderIcon" : "FileIcon"
            let imageView = UIImageView(image: UIImage(named: imageName))
            imageView.contentMode = .scaleAspectFit
            return imageView
        }()

        textField = UITextField()
        textField.text = node.name
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

    private func setupViews() {

        let actionsListLabel: UILabel = {
            let l = UILabel()
            l.translatesAutoresizingMaskIntoConstraints = false
            l.textColor = .darkGray
            l.text = NSLocalizedString("Rename utilities:", comment: "")
            l.font = UIFont.systemFont(ofSize: 16)
            return l
        }()

        let actionsContainerView: UIView = {
            let v = UIView()
            v.layer.cornerRadius = 5
            v.translatesAutoresizingMaskIntoConstraints = false
            v.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 1.0, alpha: 1.0)
            return v
        }()

        let convert_type_0_Button = RenameUtilitiesButton(title: NSLocalizedString("Replace underscore with space", comment: ""),
                                                          delegate: self,
                                                          selector: #selector(handleConvert(_:)),
                                                          tag: 0)

        let convert_type_1_Button = RenameUtilitiesButton(title: NSLocalizedString("Replace space with underscore", comment: ""),
                                                          delegate: self,
                                                          selector: #selector(handleConvert(_:)),
                                                          tag: 1)

        let convert_type_2_Button = RenameUtilitiesButton(title: NSLocalizedString("Change to Sentence Case", comment: ""),
                                                          delegate: self,
                                                          selector: #selector(handleConvert(_:)),
                                                          tag: 2)

        let convert_type_3_Button = RenameUtilitiesButton(title: NSLocalizedString("Change to lower case", comment: ""),
                                                          delegate: self,
                                                          selector: #selector(handleConvert(_:)),
                                                          tag: 3)

        let convert_type_4_Button = RenameUtilitiesButton(title: NSLocalizedString("Change to UPPER CASE", comment: ""),
                                                          delegate: self,
                                                          selector: #selector(handleConvert(_:)),
                                                          tag: 4)

        let actionButtonsStackview: UIStackView = {
            let s = UIStackView(arrangedSubviews: [convert_type_0_Button, convert_type_1_Button, convert_type_2_Button,
                                                   convert_type_3_Button, convert_type_4_Button])
            s.translatesAutoresizingMaskIntoConstraints = false
            s.alignment = .fill
            s.axis = .vertical
            s.spacing = 10
            return s
        }()

        view.addSubview(tableView)

        tableView.addSubview(messageLabel)

        view.addSubview(actionsContainerView)
        actionsContainerView.addSubview(actionsListLabel)
        actionsContainerView.addSubview(actionButtonsStackview)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),

            messageLabel.topAnchor.constraint(equalTo: tableView.topAnchor, constant: 100),
            messageLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),

            actionsContainerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            actionsContainerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            actionsContainerView.topAnchor.constraint(equalTo: messageLabel.topAnchor, constant: 40),
            actionsContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),

            actionsListLabel.topAnchor.constraint(equalTo: actionsContainerView.topAnchor, constant: 10),
            actionsListLabel.leftAnchor.constraint(equalTo: actionsContainerView.leftAnchor, constant: 20),

            actionButtonsStackview.topAnchor.constraint(equalTo: actionsContainerView.topAnchor, constant: 40),
            actionButtonsStackview.leftAnchor.constraint(equalTo: actionsContainerView.leftAnchor, constant: 20),
        ])

        tableView.isScrollEnabled = false

        leftBarButton = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: ""),
                                        style: .plain,
                                        target: self,
                                        action: #selector(handleCancel))
        rightBarButton = UIBarButtonItem(title: NSLocalizedString("Rename", comment: ""),
                                         style: .plain,
                                         target: self,
                                         action: #selector(handleRename))

        self.navigationItem.setLeftBarButton(leftBarButton, animated: false)
        self.navigationItem.setRightBarButton(rightBarButton, animated: false)

        // disable Rename button
        rightBarButton.isEnabled = false

        self.title = node.type == "dir" ?
            NSLocalizedString("Rename Directory", comment: "") :
            NSLocalizedString("Rename File", comment: "")
    }

    fileprivate func positionCursor() {
        guard let elementName = textField.text else { return }

        // file has an extension?
        let elementExtension = (elementName as NSString).pathExtension
        if elementExtension == "" { return }

        // setting the cursor in the textField before the extension including the "."
        if let range = elementName.range(of: elementExtension) {
            let index: Int = elementName.distance(from: elementName.startIndex, to: range.lowerBound).advanced(by: -1)
            if let newPosition = textField.position(from: textField.beginningOfDocument, offset: index) {
                textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
            }
        }
    }

    private func hasInvalidCharacters(name: String) -> Bool {
        let charset: Set<Character> = ["\\", "/", ":", "?", "<", ">", "\"", "|"]
        return !charset.isDisjoint(with: name.characters)
    }

    private func setRenameButtonActive(_ value: Bool) {
        self.rightBarButton.isEnabled = value

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
        textField.resignFirstResponder()
        onFinish?(nil, needRefresh)
    }

    @objc fileprivate func handleRename() {

        // block a second Rename request
        setRenameButtonActive(false)

        textField.resignFirstResponder()

        // TODO: Show on screen spinner for rename request

        // get the new name, space trimmed
        let charSet = CharacterSet.whitespaces
        guard let newName = textField.text?.trimmingCharacters(in: charSet) else { return }
        
        // network request for rename
        DigiClient.shared.renameNode(at: self.nodeLocation, with: newName) { (statusCode, error) in
            // TODO: Stop spinner
            guard error == nil else {
                // TODO: Show message for error
                print("Error: \(error!.localizedDescription)")
                return
            }
            if let code = statusCode {
                switch code {
                case 200:
                    // Rename successfully completed
                    self.onFinish?(newName, true)
                case 400:
                    // Bad request ( Node already exists, invalid file name?)
                    // show message and wait for a new name or cancel action
                    let message = NSLocalizedString("This name already exists. Please choose a different one.", comment: "")
                    self.setMessage(onScreen: true, message)
                case 404:
                    // Not Found (Node do not exists anymore), folder will refresh
                    let message = NSLocalizedString("File is no longer available. Directory will refresh.", comment: "")
                    self.needRefresh = true
                    self.leftBarButton.title = NSLocalizedString("Done", comment: "")
                    self.setMessage(onScreen: true, message)
                default :
                    let message = NSLocalizedString("Server replied with Status Code: ", comment: "")
                    self.needRefresh = true
                    self.setMessage(onScreen: true, message + String(code))
                }
            }
        }
    }

    @objc private func handleTextFieldChange() {
        if let newName = textField.text {
            if newName.isEmpty {
                setRenameButtonActive(false)
            } else if hasInvalidCharacters(name: newName) {
                let message = NSLocalizedString("Characters \\ / : ? < > \" | are not allowed.", comment: "")
                setMessage(onScreen: true, message)
                setRenameButtonActive(false)
            } else if node.name.lowercased() == newName.lowercased() {
                let message = NSLocalizedString("Name is the same.", comment: "")
                setMessage(onScreen: true, message)
                setRenameButtonActive(false)
            } else {
                setMessage(onScreen: false)
                setRenameButtonActive(true)
            }
        }
    }

    @objc private func handleConvert(_ sender: UIButton) {
        guard let string = textField.text, string.characters.count > 0 else { return }

        switch sender.tag {
        case 0:
            // Replace underscore with space
            textField.text = string.replacingOccurrences(of: "_", with: " ")
        case 1:
            // Replace space with underscore
            textField.text = string.replacingOccurrences(of: " ", with: "_")
        case 2:
            // Change to Sentence Case
            let components = string.components(separatedBy: ".")
            if components.count > 1 {
                let filename = components.dropLast().joined(separator: ".")
                let fileExtension = components.last!
                textField.text = filename.capitalized.appending(".").appending(fileExtension)
            } else {
                textField.text = string.capitalized
            }
        case 3:
            // Change to lower case
            textField.text = textField.text?.lowercased()
        case 4:
            // Change to UPPER CASE
            let components = string.components(separatedBy: ".")
            if components.count > 1 {
                let filename = components.dropLast().joined(separator: ".")
                let fileExtension = components.last!
                textField.text = filename.uppercased().appending(".").appending(fileExtension)
            } else {
                textField.text = string.uppercased()
            }
        default:
            break
        }
        handleTextFieldChange()
    }
}

extension RenameViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.setMessage(onScreen: false)
        self.positionCursor()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.rightBarButton.isEnabled {
            textField.resignFirstResponder()
            self.handleRename()
            return false
        }
        return false
    }
}
