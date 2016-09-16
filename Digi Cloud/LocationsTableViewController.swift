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
    
    var user: User!
    
    var locations = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
    
       let url = Utils.getURLFromParameters(path: Constants.DigiAPI.Paths.User,
                                            parameters: nil)
        
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
                    if let dict = json as? [String: String] {
                        
                        self.user = User(firstName: dict["firstName"]!,
                                    lastName: dict["lastName"]!,
                                    email: dict["email"]!)
                    }
                    
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Welcome", message: self.user.firstName + 	" " + self.user.lastName, preferredStyle: UIAlertControllerStyle.alert)
                        let actionOK = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
                        alert.addAction(actionOK)
                        self.present(alert, animated: false, completion: nil)
                    }
                    
                    
                }
                catch let error {
                    print(error)
                }
            }
        }
        
        datatask?.resume()

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return locations.count
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
 

}
