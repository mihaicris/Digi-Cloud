//
//  renameViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 21/10/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class RenameViewController: UITableViewController {
    
    init(element: File) {
        self.element = element
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var element: File
    
    private var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.isScrollEnabled = false
        
        let leftBarButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        let rightBarButton = UIBarButtonItem(title: "Rename", style: .plain, target: self, action: #selector(handleRename))
        
        self.navigationItem.setLeftBarButton(leftBarButton, animated: true)
        self.navigationItem.setRightBarButton(rightBarButton, animated: true)
        
        let title = element.type == "dir" ? NSLocalizedString("Rename folder", comment: "") : NSLocalizedString("Rename file", comment: "")
        self.title = title
    }
    
    func handleCancel() {
        textField.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    func handleRename() {
        
        // TODO Handle Rename Network request
        textField.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
        
        textField = {
            let view = UITextField()
            view.text = element.name
            return view
        }()
        
        cell.contentView.addSubview(elementIcon)
        cell.contentView.addSubview(textField)
        cell.contentView.addConstraints(with: "H:|-12-[v0(26)]-10-[v1]-12-|", views: elementIcon, textField)
        cell.contentView.addConstraints(with: "V:[v0(26)]", views: elementIcon)
        cell.contentView.addConstraints(with: "V:|[v0]|", views: textField)
        elementIcon.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
        
        return cell
    }
    
    
}
