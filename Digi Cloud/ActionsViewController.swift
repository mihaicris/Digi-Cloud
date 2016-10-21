//
//  ActionsViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 20/10/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class ActionsViewController: UITableViewController {
    
    var element: File!
    
    var contextMenuFileActions: [ActionCell] = []
    var contextMenuFolderActions: [ActionCell] = []
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.preferredContentSize.width = 400
        self.preferredContentSize.height = tableView.contentSize.height - 1
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        
        let folderActions = [ActionCell(title: "Share", tag: 0),
                             ActionCell(title: "Copy", tag: 3),
                             ActionCell(title: "Move", tag: 4),
                             ActionCell(title: "Folder info", tag: 6)]
        
        contextMenuFolderActions.append(contentsOf: folderActions)
        
        let fileActions = [ActionCell(title: "Share", tag: 0),
                           ActionCell(title: "Make available offline", tag: 1),
                           ActionCell(title: "Rename", tag: 2),
                           ActionCell(title: "Copy", tag: 3),
                           ActionCell(title: "Move", tag: 4),
                           ActionCell(title: "Delete", tag: 5)]
        
        contextMenuFileActions.append(contentsOf: fileActions)
        
        let headerView: UIView = {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 54))
            view.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
            return view
        }()
        
        let iconImage: UIImageView = {
            let imageName = element.type == "dir" ? "FolderIcon" : "FileIcon"
            let imageView = UIImageView(image: UIImage(named: imageName))
            imageView.contentMode = .scaleAspectFit
            return imageView
        }()
        
        let elementName: UILabel = {
            let label = UILabel()
            label.text = element.name
            label.font = UIFont.systemFont(ofSize: 16)
            return label
        }()
        
        let separator: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor(white: 0.8, alpha: 1)
            return view
        }()
        
        headerView.addSubview(iconImage)
        headerView.addSubview(elementName)
        
        headerView.addConstraints(with: "H:|-22-[v0(26)]-10-[v1]-10-|", views: iconImage, elementName)
        headerView.addConstraints(with: "V:[v0(26)]", views: iconImage)
        iconImage.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        elementName.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        
        headerView.addSubview(separator)
        headerView.addConstraints(with: "H:|[v0]|", views: separator)
        headerView.addConstraints(with: "V:[v0(\(1/UIScreen.main.scale))]|", views: separator)
        
        tableView.isScrollEnabled = false
        tableView.rowHeight = 50
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return element.type == "dir" ? contextMenuFolderActions.count :contextMenuFileActions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return element.type == "dir" ? contextMenuFolderActions[indexPath.row] : contextMenuFileActions[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let tag = tableView.cellForRow(at: indexPath)?.tag {
            print(tag)
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc fileprivate func handleRename(){
        guard let name = element?.name else { return }
        let parentPath = DigiClient.shared.currentPath.last!
        let elementPath = parentPath + name
        let newName = "test.txt"
        
        DigiClient.shared.renameElement(mount: DigiClient.shared.currentMount, elementPath: elementPath, newName: newName) { (status, error) in
            
            if error != nil {
                print(error)
            } else {
                print(status)
            }
        }
        //        delegate?.renameElement(at: elementPath)
        dismiss(animated: true, completion: nil)
    }
}

class ActionCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    convenience init(title: String, tag: Int) {
        self.init()
        self.textLabel?.text = title
        self.textLabel?.textColor = .defaultColor
        self.textLabel?.font = UIFont.systemFont(ofSize: 16)
        self.tag = tag
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}











