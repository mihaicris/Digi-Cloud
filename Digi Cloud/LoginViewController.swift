//
//  LoginViewController.swift
//  test
//
//  Created by Mihai Cristescu on 15/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

final class LoginViewController: UIViewController {

    // MARK: - Properties

    var onSuccess: ((User) -> Void)?

    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        return spinner
    }()

    private lazy var usernameTextField: LoginField = {
        let field = LoginField()
        field.textFieldName = NSLocalizedString("EMAIL ADDRESS", comment: "").uppercased()

        #if DEBUG
            let dict = ProcessInfo.processInfo.environment
            field.text = dict["USERNAME"] ?? ""
        #endif

        field.delegate = self
        return field
    }()

    private lazy var passwordTextField: LoginField = {
        let field = LoginField()
        field.textFieldName = NSLocalizedString("PASSWORD", comment: "").uppercased()

        #if DEBUG
            let dict = ProcessInfo.processInfo.environment
            field.text = dict["PASSWORD"] ?? ""
        #endif

        field.isSecureTextEntry = true
        field.delegate = self
        return field
    }()

    private let loginButton: LoginButton = {
        let button = LoginButton()
        button.setTitle(NSLocalizedString("LOGIN", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()

    private let cancelButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("✕", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = UIFont(name: "Helvetica", size: 22)
        b.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return b
    }()

    private let forgotPasswordButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle(NSLocalizedString("Forgot password?", comment: ""), for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 14)
        b.addTarget(self, action: #selector(handleForgotPassword), for: .touchUpInside)
        return b
    }()

    // MARK: - Initializers and Deinitializers

    deinit { DEINITLog(self) }

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
        usernameTextField.becomeFirstResponder()
    }

    // MARK: - Helper Functions

    private func setupViews() {

        view.backgroundColor = UIColor.init(red: 40/255, green: 78/255, blue: 65/255, alpha: 1.0)

        let titleTextView: UITextView = {
            let tv = UITextView()
            tv.backgroundColor = .clear
            tv.textColor = .white
            tv.textAlignment = .center
            tv.isEditable = false
            tv.isSelectable = false
            tv.isScrollEnabled = false
            tv.translatesAutoresizingMaskIntoConstraints = false

            let aText = NSMutableAttributedString(string: NSLocalizedString("Hello!", comment: ""),
                                                  attributes: [NSFontAttributeName: UIFont(name: "PingFangSC-Semibold", size: 28)!,
                                                               NSForegroundColorAttributeName: UIColor.white])
            aText.append(NSAttributedString(string: "\n\n"))
            aText.append(NSAttributedString(string: NSLocalizedString("Please provide the credentials for your Digi Storage account.", comment: ""),
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
        view.addSubview(usernameTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        view.addSubview(spinner)
        view.addSubview(forgotPasswordButton)

        NSLayoutConstraint.activate([
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            cancelButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
            titleTextView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            titleTextView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleTextView.bottomAnchor.constraint(equalTo: usernameTextField.topAnchor),
            titleTextView.widthAnchor.constraint(equalTo: usernameTextField.widthAnchor),
            usernameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            usernameTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),
            usernameTextField.widthAnchor.constraint(equalToConstant: 340),
            usernameTextField.heightAnchor.constraint(equalToConstant: 50),
            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 20),
            passwordTextField.widthAnchor.constraint(equalTo: usernameTextField.widthAnchor),
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

    @objc private func handleForgotPassword() {
        let alert = UIAlertController(title: NSLocalizedString("Information", comment: ""),
                                      message: NSLocalizedString("Please contact RCS RDS for password information.", comment: ""),
                                      preferredStyle: UIAlertControllerStyle.alert)

        let actionOK = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.default, handler: nil)

        alert.addAction(actionOK)
        self.present(alert, animated: false, completion: nil)
        return
    }

    @objc private func handleCancel() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func handleLogin() {

        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()

        guard let username = usernameTextField.text?.lowercased(),
            let password = passwordTextField.text,
            username.characters.count > 0,
            password.characters.count > 0
            else {
                let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""),
                                              message: NSLocalizedString("Please fill in the fields.", comment: ""),
                                              preferredStyle: UIAlertControllerStyle.alert)
                let actionOK = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.default, handler: nil)
                alert.addAction(actionOK)
                self.present(alert, animated: false, completion: nil)
                return
        }

        spinner.startAnimating()

        DigiClient.shared.authenticate(username: username, password: password) { token, error in

            guard error == nil else {
                self.spinner.stopAnimating()
                self.showError()
                return
            }

            guard let token = token else {
                self.spinner.stopAnimating()
                self.showError()
                return
            }

            AppSettings.saveUser(forToken: token) { (user, error) in
                guard error == nil else {
                    self.spinner.stopAnimating()
                    self.showError()
                    return
                }

                if let user = user {
                    self.dismiss(animated: true) {
                        self.onSuccess?(user)
                    }
                } else {
                    self.spinner.stopAnimating()
                    self.showError()
                }
            }
        }
    }

    private func showError() {
        let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""),
                                      message: NSLocalizedString("An error has occurred.\nPlease try again later!", comment: ""),
                                      preferredStyle: UIAlertControllerStyle.alert)
        let actionOK = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(actionOK)
        self.present(alert, animated: false, completion: nil)
    }

}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
