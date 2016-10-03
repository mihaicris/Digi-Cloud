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
    
    var emailTextField: UITextField = {
        let field = UITextField()
        field.text = "mihai.cristescu@gmail.com"
        
        field.textColor = UIColor(colorLiteralRed: 63/255, green: 63/255, blue: 63/255, alpha: 1.0)
        field.font = UIFont(name: "Helvetica-Bold", size: 16)
        field.backgroundColor = .white
        field.borderStyle = .roundedRect
        field.autocorrectionType = .no
        field.spellCheckingType = .no
        field.translatesAutoresizingMaskIntoConstraints = false
        field.contentVerticalAlignment = .bottom
        
        return field
    }()
    
    var passwordTextField: UITextField = {
        let field = UITextField()
        
        field.textColor = UIColor(colorLiteralRed: 63/255, green: 63/255, blue: 63/255, alpha: 1.0)
        field.font = UIFont(name: "Helvetica-Bold", size: 16)
        field.backgroundColor = .white
        field.borderStyle = .roundedRect
        field.autocorrectionType = .no
        field.spellCheckingType = .no
        field.translatesAutoresizingMaskIntoConstraints = false
        field.contentVerticalAlignment = .bottom
        
        field.isSecureTextEntry = true
        return field
    }()
    
    var loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("LOGIN", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.setTitleColor(.white, for: UIControlState.normal)
        button.backgroundColor = UIColor(colorLiteralRed: 59/255, green: 55/255, blue: 148/255, alpha: 1.0)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(nil, action: #selector(LoginViewController.handleLogin), for: .touchUpInside)
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
        
        view.backgroundColor = UIColor(colorLiteralRed: 77/255, green: 70/255, blue: 187/255, alpha: 1.0)
        
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        view.addSubview(spinner)
        
        let views: [String: AnyObject] = ["v0": emailTextField, "v1": passwordTextField, "v2": loginButton, "v3": spinner]
        
        emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalToConstant: 300).isActive = true
        passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalToConstant: 300).isActive = true
        loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-300-[v0(50)]-30-[v1(50)]-30-[v2(40)]-30-[v3]",
                                                           options: NSLayoutFormatOptions(),
                                                           metrics: nil,
                                                           views: views))
        
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


