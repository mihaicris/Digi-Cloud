//
//  ViewController.swift
//  test
//
//  Created by Mihai Cristescu on 15/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    // MARK: - Create UI Elements
    
    var emailTextField: CustomTextField = {
        let field = CustomTextField()
        field.text = "mihai.cristescu@gmail.com"
        return field
    }()
    
    var passwordTextField: CustomTextField = {
        let field = CustomTextField()
        field.text = "bambambam"
        field.isSecureTextEntry = true
        return field
    }()
    
    var loginButton: CustomLoginButton = {
        let button = CustomLoginButton()
        button.setTitle("LOGIN", for: .normal)
        return button
    }()
    
    var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    func handleLogin() {
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
                    self.openLocations()
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
    
    func openLocations() {
        
        let navigationController = UINavigationController(rootViewController: LocationsTableViewController())
        navigationController.navigationItem.title = "Locations"
        present(navigationController, animated: true, completion: nil)
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(colorLiteralRed: 96/255, green: 95/255, blue: 199/255, alpha: 1.0)
        
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        
        loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)

        view.addSubview(spinner)
        
//        let views: [String: AnyObject] = ["v0": emailTextField, "v1": passwordTextField, "v2": loginButton, "v3": spinner]
        
        emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalToConstant: 300).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true

        
        passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalToConstant: 300).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true

        
        loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 40).isActive = true

        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        emailTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -150).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 30).isActive = true
        loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 30).isActive = true
        spinner.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20)
        
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


