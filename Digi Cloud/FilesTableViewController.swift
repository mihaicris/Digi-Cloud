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
    
    var token: String!
    
    var mount: String!
    
    var url: URL!
    
    private var content: [File] = []
    
    private var cellForInset: UITableViewCell!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var request = URLRequest(url: url)
        
        request.addValue("Token " + token, forHTTPHeaderField: "Authorization")
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let defaultSession = URLSession(configuration: URLSessionConfiguration.default)
        
        let datatask: URLSessionDataTask?
        
        datatask = defaultSession.dataTask(with: request) {
            (dataResponse: Data?, response: URLResponse?, error: Error?) in
            
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            
            if error != nil {
                print("Session error")
                return
            }
            
            if let data = dataResponse {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    guard let dict = json as? [String: Any],
                        let objs = dict["files"] as? [[String: Any]]
                        else {
                            print("Could not parce objects from json")
                            return
                    }
                    
                    for item in objs {
                        if let newFile = File(JSON: item) {
                            self.content.append(newFile)
                        }
                    }
                    
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
                catch let error {
                    print(error)
                }
            }
        }
        datatask?.resume()
        
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
            cell.fileSizeLabel.text = ByteCountFormatter.string(fromByteCount: Int64(data.size), countStyle: ByteCountFormatter.CountStyle.file) + "・" + modifiedDate
            
            return cell
        }
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if content[indexPath.row].type == "dir" {
            
            if let newVC = self.storyboard?.instantiateViewController(withIdentifier: "FilesTableViewController") as? FilesTableViewController {
                newVC.token = token
                newVC.mount = mount
                newVC.title = content[indexPath.row].name
                var urlComponents = URLComponents(string: url.absoluteString)
                let queryItems = urlComponents?.queryItems
                var path = (queryItems?.filter({$0.name == "path"}).first?.value)!
                if path != "/" {
                    path += "/"
                }
                let newPath = path + content[indexPath.row].name
                newVC.url = Utils.getURLForMountContent(mount: mount, path: newPath)
                self.navigationController?.pushViewController(newVC, animated: true)
            } else {
                print("Error loading new controller")
            }
            
        } else {
            
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
            
            var urlComponents = URLComponents(string: url.absoluteString)
            let queryItems = urlComponents?.queryItems
            var path = (queryItems?.filter({$0.name == "path"}).first?.value)!
            if path != "/" {
                path += "/"
            }
            let newPath = path + file.name
            contentVC.token = token
            contentVC.mount = mount
            contentVC.title = file.name
            contentVC.url = Utils.getURLForFileContent(mount: mount, path: newPath)
            print(file.contentType)
        }
        
    }
}
