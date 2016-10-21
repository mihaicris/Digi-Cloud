//
//  FilesTableViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 19/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class FilesTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    var content: [File] = []

    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(FileCell.self, forCellReuseIdentifier: "FileCell")
        tableView.register(DirectoryCell.self, forCellReuseIdentifier: "DirectoryCell")
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.rowHeight = 50
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        DigiClient.shared.getLocationContent(mount: DigiClient.shared.currentMount, queryPath: DigiClient.shared.currentPath.last!) {
            (content, error) in
            
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            
            if error != nil {
                print("Error: \(error)")
            }
            if let content = content  {
                self.content = content
                
                // TODO: Implement sorting filters in the interface
                self.content.sort {
                    /*  Order items by name (ascending), directories are shown first */
                    return $0.type == $1.type ? ($0.name < $1.name) : ($0.type < $1.type)
                    /* Order items by Date (descending), directories are shown first */
                    // return $0.type == $1.type && $0.type != "dir" ? ($0.modified > $1.modified) : ($0.type < $1.type)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    deinit {
        DigiClient.shared.currentPath.removeLast()
    }
    
    // MARK: - Table View Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return content.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = content[indexPath.row]
        
        if data.type == "dir" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DirectoryCell", for: indexPath) as! DirectoryCell
            cell.delegate = self
            
            cell.folderNameLabel.text = data.name
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FileCell", for: indexPath) as! FileCell
            cell.delegate = self
           
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            formatter.locale = Locale.current
            formatter.dateFormat = "dd.MM.YYY・HH:mm"
            
            let modifiedDate = formatter.string(from: Date(timeIntervalSince1970: data.modified/1000))
            cell.fileNameLabel.text = data.name
            
            let fileSizeString = ByteCountFormatter.string(fromByteCount: Int64(data.size), countStyle: ByteCountFormatter.CountStyle.file) + "・" + modifiedDate
            cell.fileSizeLabel.text = fileSizeString
            
            return cell
        }
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        let itemName = content[indexPath.row].name
        let previousPath = DigiClient.shared.currentPath.last!
        
        if content[indexPath.row].type == "dir" {
            // This is a Folder
            let controller = FilesTableViewController()
            controller.title = itemName
            
            let folderPath = previousPath + itemName + "/"
            DigiClient.shared.currentPath.append(folderPath)
            
            navigationController?.pushViewController(controller, animated: true)
            
        } else {
            // This is a file
            let controller = ContentViewController()
            controller.title = itemName

            let filePath = previousPath + itemName
            DigiClient.shared.currentPath.append(filePath)
            
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension FilesTableViewController: FilesTableViewControllerDelegate {

    func showActionController(for sourceView: UIView) {
        
        let buttonPosition = sourceView.convert(CGPoint.zero, to: self.tableView)
        guard let indexPath = tableView.indexPathForRow(at: buttonPosition) else { return }
        
        let controller = ActionsViewController(style: .plain)
        
        controller.element = self.content[indexPath.row]
        controller.modalPresentationStyle = .popover
        
        controller.popoverPresentationController?.sourceView = sourceView
        controller.popoverPresentationController?.sourceRect = sourceView.bounds
        present(controller, animated: true, completion: nil)
    }
    
}



