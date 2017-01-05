//
//  LoginViewController.swift
//  test
//
//  Created by Mihai Cristescu on 15/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    // MARK: - Properties

    var onFinish: (() -> Void)?

    let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        return spinner
    }()

    lazy var emailTextField: LoginField = {
        let field = LoginField()
        field.textFieldName = NSLocalizedString("EMAIL ADDRESS", comment: "TextField Name").uppercased()

        #if DEBUG
        let dict = ProcessInfo.processInfo.environment
        field.text = dict["USERNAME"] ?? ""
        #endif

        field.delegate = self
        return field
    }()

    lazy var passwordTextField: LoginField = {
        let field = LoginField()
        field.textFieldName = NSLocalizedString("PASSWORD", comment: "TextField Name").uppercased()

        #if DEBUG
        let dict = ProcessInfo.processInfo.environment
        field.text = dict["PASSWORD"] ?? ""
        #endif

        field.isSecureTextEntry = true
        field.delegate = self
        return field
    }()

    lazy var loginButton: LoginButton = {
        let button = LoginButton()
        button.setTitle(NSLocalizedString("LOGIN", comment: "Button Title"), for: .normal)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()

    // MARK: - Initializers and Deinitializers

    #if DEBUG
    deinit {
        print("[DEINIT]: " + String(describing: type(of: self)))
    }
    #endif

    // MARK: - Overridden Methods and Properties

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emailTextField.becomeFirstResponder()
    }

    // MARK: - Helper Functions

    fileprivate func setupViews() {
        view.backgroundColor = UIColor(colorLiteralRed: 96 / 255, green: 95 / 255, blue: 199 / 255, alpha: 1.0)

        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        view.addSubview(spinner)

        emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emailTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -150).isActive = true
        emailTextField.widthAnchor.constraint(equalToConstant: 300).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true

        passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 30).isActive = true
        passwordTextField.widthAnchor.constraint(equalToConstant: 300).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true

        loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 30).isActive = true
        loginButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 40).isActive = true

        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20).isActive = true
    }

    @objc func handleLogin() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }

        spinner.startAnimating()

        DigiClient.shared.authenticate(email: email, password: password) {
            (success, _) in
            self.spinner.stopAnimating()
            if success {
                // save token for automatic login
                AppSettings.accountLoggedIn = email
                self.onFinish?()
            } else {
                    let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Window Title"),
                                                message: NSLocalizedString("Unauthorized access", comment: "Error Message"),
                                         preferredStyle: UIAlertControllerStyle.alert)

                    let actionOK = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
                    alert.addAction(actionOK)
                    self.present(alert, animated: false, completion: nil)
            }
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
