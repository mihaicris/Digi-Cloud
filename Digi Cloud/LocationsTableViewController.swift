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
    
    var mounts: [Mount] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = Utils.getURLFromParameters(path: Constants.DigiAPI.Paths.Mounts, parameters: nil)
        
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
                    let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
                    guard let dict = json as? [String: AnyObject],
                        let mountsList = dict["mounts"] as? [AnyObject] else { return }
                    for item in mountsList  {
                        guard let mount = item as? [String:AnyObject],
                            let mountName = mount["name"] as? String,
                            let mountId = mount["id"] as? String else { return }
                        let mountObject = Mount(id: mountId, name: mountName)
                        self.mounts.append(mountObject)
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
        return mounts.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
        
        cell.textLabel?.text = mounts[indexPath.row].name
        return cell
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Constants.Segues.toFiles {
            if let destVC = segue.destination as? FilesTableViewController {
                guard let cell = sender as? UITableViewCell else { return }
                guard let indexPath = tableView.indexPath(for: cell) else { return }
                destVC.token = token
                destVC.mount = mounts[indexPath.row].id
                destVC.title = mounts[indexPath.row].name
                destVC.url = Utils.getURLForMountContent(mount: mounts[indexPath.row].id, path: "/")
            }
        }
        
    }
}
