//
//  LocationTableTableViewController.swift
//  test
//
//  Created by Mihai Cristescu on 15/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class LocationsTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    var mounts: [Mount] = []
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        DigiClient.shared().getLocations() {
            (mounts, error) in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            if error != nil {
                print("Error: \(error)")
            }
            if let mounts = mounts  {
                self.mounts = mounts
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - Navigation
    
    func openMount() {
            let controller = FilesTableViewController()
            DigiClient.shared().currentMount = mounts[0].id
            DigiClient.shared().currentPath.append("/")
            controller.title = mounts[0].name
            navigationController?.pushViewController(controller, animated: true)
        }
        
        // MARK: - Table View Data Source
        
        override func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return mounts.count
        }
        
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
            cell.textLabel?.text = mounts[indexPath.row].name
            return cell
        }
}
