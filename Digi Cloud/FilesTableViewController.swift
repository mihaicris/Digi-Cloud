//
//  FilesTableViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 19/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class FilesTableViewController: UITableViewController {
    
    var token: String!
    
    var url: URL!

    var content: [File] = []

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
                    let json = try JSONSerialization.jsonObject(with: data,
                                                                options: JSONSerialization.ReadingOptions.allowFragments)
                    
                    guard let dict = json as? [String: AnyObject] else { return }
                    
                    guard let objs = dict["files"] as? [[String:AnyObject]] else { return }
                    
                    for item in objs {
                        guard let name = item["name"] as? String,
                            let type = item["type"] as? String,
                            let modified = item["modified"] as? TimeInterval,
                            let size = item["size"] as? Double,
                            let contentType = item["contentType"] as? String
                        else {
                                print("Could not parce keys")
                                return
                        }
                        
                        let newFile = File(name: name, type: type, modified: modified, size: size, contentType: contentType)
                        
                        self.content.append(newFile)
                    }
                    
                    self.content.sort {
                        return $0.type == $1.type ? ($0.name < $1.name) : ($0.type < $1.type)
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

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return content.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FileCell", for: indexPath)
        cell.textLabel?.text = content[indexPath.row].name
        return cell
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }

}
