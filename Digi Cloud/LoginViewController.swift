//
//  ViewController.swift
//  test
//
//  Created by Mihai Cristescu on 15/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    var emailTextField: UITextField = {
        let field = UITextField()
        return field
    }()
    
    var passwordTextField: UITextField = {
        let field = UITextField()
        return field
    }()
    
    var loginButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 0.8
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.shadowRadius = 40
        button.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        button.layer.shadowOpacity = 0.5
        button.layer.shadowColor = UIColor.white.cgColor
        return button
    }()
    
    var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    // MARK: - Actions
    
    @IBAction func loginButtonTouchUp(_ sender: UIButton) {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        spinner.startAnimating()
        DigiClient.shared().authenticate(email: email, password: password) {
            (success, error) in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.spinner.stopAnimating()
            }
            if success {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "Locations", sender: nil)
                }
            } else {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error",
                                                  message: "Unauthorized access",
                                                  preferredStyle: UIAlertControllerStyle.alert)
                    let actionOK = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
                    alert.addAction(actionOK)
                    self.present(alert, animated: false, completion: nil)
                }
            }
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Locations" {
            if let nextViewController = segue.destination.contentViewController as? LocationsTableViewController {
                nextViewController.title = "Locations"
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


