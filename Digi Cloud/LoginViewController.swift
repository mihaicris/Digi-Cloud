//
//  ViewController.swift
//  test
//
//  Created by Mihai Cristescu on 15/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton! {
        didSet {
            loginButton.layer.cornerRadius = 20
            loginButton.layer.borderWidth = 0.8
            loginButton.layer.borderColor = UIColor.white.cgColor
            loginButton.layer.shadowRadius = 40
            loginButton.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            loginButton.layer.shadowOpacity = 0.5
            loginButton.layer.shadowColor = UIColor.white.cgColor
        }
    }
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    // MARK: - Actions
    
    @IBAction func loginButtonTouchUp(_ sender: UIButton) {
        
        guard let email = emailTextField.text else { return }
        guard let pass = passwordTextField.text else { return }
        
        let url = Utils.getURLFromParameters(path: API.Paths.Token, parameters: nil)
        
        var request = URLRequest(url: url)
        
        request.addValue(email, forHTTPHeaderField: "X-Koofr-Email")
        request.addValue(pass, forHTTPHeaderField: "X-Koofr-Password")
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        spinner.startAnimating()
        
        let defaultSession = URLSession(configuration: URLSessionConfiguration.default)
        
        let datatask: URLSessionDataTask?
        
        datatask = defaultSession.dataTask(with: request) {
            (data: Data?, response: URLResponse?, error: Error?) in
            
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.spinner.stopAnimating()
                
            }
            
            if error != nil {
                print("Error: \(error!.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                
                if httpResponse.statusCode == 200 {
                    for header in httpResponse.allHeaderFields {
                        if let key = header.key as? String,
                            key == "x-koofr-token" {
                            self.token = header.value as? String
                            if self.token != nil {
                                
                                DispatchQueue.main.async {
                                    self.performSegue(withIdentifier: "Locations", sender: nil)
                                }
                            }
                            
                        }
                    }
                } else {
                    
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Error", message: "Unauthorized access", preferredStyle: UIAlertControllerStyle.alert)
                        let actionOK = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
                        alert.addAction(actionOK)
                        self.present(alert, animated: false, completion: nil)
                        
                    }
                    
                }
                
            }
        }
        
        datatask?.resume()
    }
    
    // MARK: - Properties

    var token: String?

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Locations" {
            if let nextViewController = segue.destination.contentViewController as? LocationsTableViewController {
                    nextViewController.token = self.token!
                    nextViewController.title = "Digi Storage"
            }
        }
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - View Methods
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


