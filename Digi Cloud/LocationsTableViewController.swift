//
//  LocationTableTableViewController.swift
//  test
//
//  Created by Mihai Cristescu on 15/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class LocationsTableViewController: UITableViewController {
    
    var token: String!
    
    var content: [File] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //       let url = Utils.getURLFromParameters(path: Constants.DigiAPI.Paths.Mounts,
        //                                            parameters: nil)
        
        let url = Utils.getURLForMountContent(mount: "51e44dfa-d3e1-4eea-9de4-6c3068aab39b", path: "/Ebooks/C")
                
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
                        guard let name = item["name"] as? String else {
                            print("Error guard name");
                            return }
                        
                        guard let type = item["type"] as? String else {
                            print("Error guard type");
                            return }
                        
                        guard let modified = item["modified"] as? TimeInterval else {
                            print("Error guard modified");
                            return }
                        
                        guard let size = item["size"] as? Double else {
                            print("Error guard size");
                            return }
                        
                        guard let contentType = item["contentType"] as? String else {
                            print("Error guard contentType");
                            return }
                        
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Locations"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return content.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
        
        cell.textLabel?.text = content[indexPath.row].name
        
        return cell
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
