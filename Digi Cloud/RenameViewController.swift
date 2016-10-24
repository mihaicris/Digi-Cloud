//
//  renameViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 21/10/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class RenameViewController: UITableViewController {

    var elementIndexPath: IndexPath
    var controller: FilesTableViewController
    fileprivate var element: File
    fileprivate let oldName: String
    fileprivate var rightBarButton: UIBarButtonItem!
    fileprivate var textField: UITextField!

    init(controller: FilesTableViewController, indexPath: IndexPath) {
        self.elementIndexPath = indexPath
        self.controller = controller
        element = controller.content[indexPath.row]
        oldName = element.name
        super.init(style: .grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView(frame: CGRect.zero)
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        enterEditMode()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()

        let elementIcon: UIImageView = {
            let imageName = element.type == "dir" ? "FolderIcon" : "FileIcon"
            let imageView = UIImageView(image: UIImage(named: imageName))
            imageView.contentMode = .scaleAspectFit
            return imageView
        }()

        textField = UITextField()
        textField.text = element.name
        textField.clearButtonMode = .whileEditing
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

    private func enterEditMode() {
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
                    DispatchQueue.main.async {
                        self.controller.content[self.elementIndexPath.row].name = name
                        self.controller.tableView.reloadRows(at: [self.elementIndexPath], with: .automatic)
                        self.dismiss(animated: true, completion: nil)
                    }
                case 400:
                    // TODO: File already exists
                    print(status)
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

    deinit {
        print("Rename deinit")
    }
}

extension RenameViewController: UITextFieldDelegate {
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return !(textField.text?.isEmpty ?? true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


