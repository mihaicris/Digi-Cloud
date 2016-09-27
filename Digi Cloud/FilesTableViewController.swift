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
    
    private var content: [File] = []
    
    private var cellForInset: UITableViewCell!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        DigiClient.shared().getLocationContent(mount: DigiClient.shared().currentMount, queryPath: DigiClient.shared().currentPath.last!) {
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
        DigiClient.shared().currentPath.removeLast()
    }
    
    // MARK: - Table View Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return content.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = content[indexPath.row]
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale.current
        formatter.dateFormat = "dd.MM.YYY・HH:mm"
        
        if data.type == "dir" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DirectoryCell", for: indexPath) as! DirectoryCell
            cell.folderNameLabel.text = data.name
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FileCell", for: indexPath) as! FileCell
            let modifiedDate = formatter.string(from: Date(timeIntervalSince1970: data.modified/1000))
            cell.fileNameLabel.text = data.name
            cell.fileSizeLabel.text = ByteCountFormatter.string(fromByteCount: Int64(data.size),
                                                                countStyle: ByteCountFormatter.CountStyle.file) + "・" + modifiedDate
            return cell
        }
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if content[indexPath.row].type == "dir" {
            if let contentVC = self.storyboard?.instantiateViewController(withIdentifier: "FilesTableViewController") as? FilesTableViewController {
                contentVC.title = content[indexPath.row].name
                DigiClient.shared().currentPath.append(DigiClient.shared().currentPath.last! + content[indexPath.row].name + "/")
                self.navigationController?.pushViewController(contentVC, animated: true)
            } else {
                print("Error loading new controller")
            }
        } else {
            // type == "file"
            if let cell = tableView.cellForRow(at: IndexPath(row: indexPath.row - 1 , section: indexPath.section)) {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                cellForInset = cell
            }
            performSegue(withIdentifier: Segues.toContent, sender: content[indexPath.row])
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if cellForInset != nil {
            cellForInset.separatorInset = UIEdgeInsets(top: 0, left: 53, bottom: 0, right: 0)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == Segues.toContent,
            let file = sender as? File
            else { return }
        
        if let contentVC = segue.destination as? ContentViewController {
            contentVC.title = file.name
            DigiClient.shared().currentPath.append(DigiClient.shared().currentPath.last! + file.name)
        }
    }
}
