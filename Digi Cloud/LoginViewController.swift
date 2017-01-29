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

    var onSuccess: ((Account) -> Void)?

    var onCancel: (() -> Void)?

    fileprivate let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        return spinner
    }()

    fileprivate lazy var emailTextField: LoginField = {
        let field = LoginField()
        field.textFieldName = NSLocalizedString("EMAIL ADDRESS", comment: "TextField Name").uppercased()

        #if DEBUG
        let dict = ProcessInfo.processInfo.environment
        field.text = dict["USERNAME"] ?? ""
        #endif

        field.delegate = self
        return field
    }()

    fileprivate lazy var passwordTextField: LoginField = {
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

    fileprivate let loginButton: LoginButton = {
        let button = LoginButton()
        button.setTitle(NSLocalizedString("LOGIN", comment: "Button Title"), for: .normal)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()

    fileprivate let cancelButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("✕", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = UIFont(name: "Helvetica", size: 22)
        b.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return b
    }()

    fileprivate let forgotPasswordButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle(NSLocalizedString("Forgot password?", comment: "Question"), for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 14)
        b.addTarget(self, action: #selector(handleForgotPassword), for: .touchUpInside)
        return b
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

        view.backgroundColor = UIColor.init(red: 40/255, green: 78/255, blue: 65/255, alpha: 1.0)

        let titleTextView: UITextView = {
            let tv = UITextView()
            tv.backgroundColor = .clear
            tv.textColor = .white
            tv.textAlignment = .center
            tv.isEditable = false
            tv.isSelectable = false
            tv.translatesAutoresizingMaskIntoConstraints = false

            let aText = NSMutableAttributedString(string: NSLocalizedString("Hello!", comment: ""),
                                                  attributes: [NSFontAttributeName: UIFont(name: "PingFangSC-Semibold", size: 28)!,
                                                               NSForegroundColorAttributeName: UIColor.white])
            aText.append(NSAttributedString(string: "\n\n"))
            aText.append(NSAttributedString(string: NSLocalizedString("Please provide the credentials for your Digi Storage account.", comment: "Information"),
                                            attributes: [NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 16)!,
                                                        NSForegroundColorAttributeName: UIColor.white]))
            let aPar = NSMutableParagraphStyle()
            aPar.alignment = .center
            let range = NSRange(location: 0, length: aText.string.characters.count)
            aText.addAttributes([NSParagraphStyleAttributeName: aPar], range: range)
            tv.textContainerInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
            tv.attributedText = aText
            return tv
        }()

        view.addSubview(cancelButton)
        view.addSubview(titleTextView)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        view.addSubview(spinner)
        view.addSubview(forgotPasswordButton)

        NSLayoutConstraint.activate([
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            cancelButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
            titleTextView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            titleTextView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleTextView.bottomAnchor.constraint(equalTo: emailTextField.topAnchor),
            titleTextView.widthAnchor.constraint(equalTo: emailTextField.widthAnchor),
            emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),
            emailTextField.widthAnchor.constraint(equalToConstant: 340),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),
            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.widthAnchor.constraint(equalTo: emailTextField.widthAnchor),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 30),
            loginButton.widthAnchor.constraint(equalToConstant: 150),
            loginButton.heightAnchor.constraint(equalToConstant: 40),
            forgotPasswordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            forgotPasswordButton.centerYAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 30),
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.topAnchor.constraint(equalTo: forgotPasswordButton.bottomAnchor, constant: 30)
        ])
    }

    @objc fileprivate func handleForgotPassword() {
        let alert = UIAlertController(title: NSLocalizedString("Information", comment: "Window Title"),
                                    message: NSLocalizedString("Please contact RCS RDS for password information.", comment: "Information"),
                             preferredStyle: UIAlertControllerStyle.alert)

        let actionOK = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)

        alert.addAction(actionOK)
        self.present(alert, animated: false, completion: nil)
        return
    }

    @objc fileprivate func handleCancel() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        self.onCancel?()
    }

    @objc fileprivate func handleLogin() {

        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()

        guard let email = emailTextField.text,
            let password = passwordTextField.text,
            email.characters.count > 0,
            password.characters.count > 0
        else {
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Window Title"),
                                          message: NSLocalizedString("Please fill in the fields.", comment: "Error Message"),
                                          preferredStyle: UIAlertControllerStyle.alert)
            let actionOK = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
            alert.addAction(actionOK)
            self.present(alert, animated: false, completion: nil)
            return
        }

        spinner.startAnimating()

        DigiClient.shared.authenticate(email: email, password: password) { token, error in

            guard error == nil else {

                self.spinner.stopAnimating()

                let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Window Title"),
                                            message: NSLocalizedString("An error has occurred.\nPlease try again later!", comment: "Error Message"),
                                     preferredStyle: UIAlertControllerStyle.alert)
                let actionOK = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
                alert.addAction(actionOK)
                self.present(alert, animated: false, completion: nil)
                return
            }

            guard let token = token else {
                let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Window Title"),
                                            message: NSLocalizedString("Unauthorized access", comment: "Error Message"),
                                     preferredStyle: UIAlertControllerStyle.alert)

                let actionOK = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
                alert.addAction(actionOK)
                self.present(alert, animated: false, completion: nil)
                return
            }

            let account = Account(account: email)

            do {
                // Save the token in the Keychain
                try account.save(token: token)

                // Save profile image view from Gravatar if exists.
                account.fetchProfileImage {

                 // Dismiss the login screen
                 self.onSuccess?(account)
                }

            } catch {
                let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Window Title"),
                                              message: NSLocalizedString("An error has occurred while saving the account.\nPlease try again later!", comment: "Error Message"),
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
