//
//  renameViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 21/10/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class RenameViewController: UITableViewController {

    var didRenamed: ((_ newName: String) -> Void)?

    fileprivate var element: File
    fileprivate let oldName: String
    fileprivate var rightBarButton: UIBarButtonItem!
    fileprivate var textField: UITextField!
    fileprivate var messageLabel: UILabel!

    init(element: File) {
        self.element = element
        oldName = element.name
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
        enterEditMode()
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
        textField.delegate = self
        textField.addTarget(self, action: #selector(handleTextFieldChange), for: .editingChanged)

        cell.contentView.addSubview(elementIcon)
        cell.contentView.addSubview(textField)
        cell.contentView.addConstraints(with: "H:|-12-[v0(26)]-10-[v1]-12-|", views: elementIcon, textField)
        cell.contentView.addConstraints(with: "V:[v0(26)]", views: elementIcon)
        cell.contentView.addConstraints(with: "V:|[v0]|", views: textField)
        elementIcon.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true

        return cell
    }

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

        let leftBarButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        rightBarButton = UIBarButtonItem(title: "Rename", style: .plain, target: self, action: #selector(handleRename))

        self.navigationItem.setLeftBarButton(leftBarButton, animated: true)
        self.navigationItem.setRightBarButton(rightBarButton, animated: true)

        // disable Rename button for now
        rightBarButton?.isEnabled = false

        let title = element.type == "dir" ? NSLocalizedString("Rename folder", comment: "") : NSLocalizedString("Rename file", comment: "")
        self.title = title
    }

    fileprivate func enterEditMode() {
        textField.becomeFirstResponder()

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

    func handleCancel() {
        textField.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }

    func handleRename() {

        textField.resignFirstResponder()

        // TODO Show on screen spinner for rename request

        // get the new name
        guard let name = textField.text else { return }

        //build the path of element to be renamed
        let elementPath = DigiClient.shared.currentPath.last! + oldName

        // network request for rename
        DigiClient.shared.renameElement(path: elementPath, newName: name) { (status, error) in

            // TODO: Stop spinner

            if error != nil {
                // TODO Show message for error
                print(error!)
            }
            if let status = status {
                switch status {
                case 200...299:
                    self.didRenamed?(name)
                    DispatchQueue.main.async {
                        self.textField.resignFirstResponder()
                        self.dismiss(animated: true, completion: nil)
                    }
                case 400:
                    self.showErrorMessage(true)
                case 404:
                    // TODO: Bad request ( File do not exists, invalid file name?)
                    print(status)
                default : print(status)
                }
            }
        }
    }

    func handleTextFieldChange() {
        if let newName = textField.text {
            if newName.isEmpty || newName.contains("/") || oldName == newName {
                rightBarButton?.isEnabled = false
            } else {
                rightBarButton?.isEnabled = true
            }
        }
    }
    fileprivate func showErrorMessage(_ value: Bool) {
        DispatchQueue.main.async {
            self.messageLabel.text = NSLocalizedString("This name already exists. Please choose a different name.", comment: "Error message")
            UIView.animate(withDuration: 0.4, animations: {
                self.view.layoutSubviews()
                self.messageLabel.alpha = value ? 1.0 : 0.0
            })
        }
    }

    deinit {
        #if DEBUG
        print("Rename deinit")
        #endif
    }
}

extension RenameViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        showErrorMessage(false)
        enterEditMode()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


