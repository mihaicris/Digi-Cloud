//
//  AccountSelectionViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 03/01/17.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import UIKit

class AccountSelectionViewController: UIViewController {

    // MARK: - Properties

    var onSelect: (() -> Void)?

    /// An array of logged users
    fileprivate var savedAccounts: [String] = []

    // MARK: - Overridden Methods and Properties

    override func viewDidLoad() {
        super.viewDidLoad()
        getSavedAccounts()
        setupViews()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Helper Functions

    fileprivate func setupViews() {

        setNeedsStatusBarAppearanceUpdate()

        view.backgroundColor = UIColor.init(red: 40/255, green: 78/255, blue: 55/255, alpha: 1.0)

        let logoBigLabel: UILabel = {
            let l = UILabel()
            l.translatesAutoresizingMaskIntoConstraints = false
            l.textColor = .white
            l.textAlignment = .center
            l.numberOfLines = 3
            let color = UIColor.init(red: 48/255, green: 133/255, blue: 243/255, alpha: 1.0)
            let attributedText = NSMutableAttributedString(string: "Digi Cloud",
                                                           attributes: [NSFontAttributeName: UIFont(name: "PingFangSC-Semibold", size: 48) as Any])
            let word = NSLocalizedString("for", comment: "a word")
            attributedText.append(NSAttributedString(string: "\n\(word)  ",
                                                 attributes: [NSFontAttributeName: UIFont(name: "Didot-Italic", size: 20) as Any]))
            attributedText.append(NSAttributedString(string: "Digi Storage",
                                                 attributes: [NSFontAttributeName: UIFont(name: "PingFangSC-Semibold", size: 20) as Any]))

            let nsString = NSString(string: attributedText.string)

            var nsRange = nsString.range(of: "Cloud")
            attributedText.addAttributes([NSForegroundColorAttributeName: color], range: nsRange)

            nsRange = nsString.range(of: "Storage")
            attributedText.addAttributes([NSForegroundColorAttributeName: color], range: nsRange)

            l.attributedText = attributedText
            return l
        }()

        let accountsContainterView: UIView = {
            let v = UIView()
            v.translatesAutoresizingMaskIntoConstraints = false
            v.backgroundColor = UIColor.init(white: 0.0, alpha: 0.1)
            v.layer.cornerRadius = 15
            v.layer.masksToBounds = true
            return v
        }()

        let noAccountsLabel: UILabel = {
            let l = UILabel()
            l.translatesAutoresizingMaskIntoConstraints = false
            l.textColor = UIColor.init(red: 161/255, green: 168/255, blue: 209/255, alpha: 1.0)
            l.text = NSLocalizedString("No accounts", comment: "Label, information")
            l.font = UIFont(name: "HelveticaNeue-light", size: 30)
            return l
        }()

        let addAccountButton: UIButton = {
            let b = UIButton(type: UIButtonType.system)
            b.translatesAutoresizingMaskIntoConstraints = false
            b.setTitle(NSLocalizedString("Add Account", comment: "Button Title"), for: .normal)
            b.setTitleColor(.white, for: .normal)
            b.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 16)
            b.addTarget(self, action: #selector(handleLoginAction), for: .touchUpInside)
            return b
        }()

        let signUpLabel: UIButton = {
            let b = UIButton(type: UIButtonType.system)
            b.translatesAutoresizingMaskIntoConstraints = false
            b.setTitle(NSLocalizedString("Sign Up for Digi Storage", comment: "Button Title"), for: .normal)
            b.setTitleColor(.white, for: .normal)
            b.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 14)
            return b
        }()

        let loginToAnotherAccountButton: UIButton = {
            let b = UIButton(type: UIButtonType.system)
            b.translatesAutoresizingMaskIntoConstraints = false
            b.setTitle(NSLocalizedString("Log in to Another Account", comment: "Button Title"), for: .normal)
            b.setTitleColor(.white, for: .normal)
            b.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 14)
            b.addTarget(self, action: #selector(handleLoginAction), for: .touchUpInside)
            return b
        }()

        view.addSubview(logoBigLabel)
        view.addSubview(accountsContainterView)
        view.addSubview(signUpLabel)

        // Constraints for any situation
        NSLayoutConstraint.activate([
            logoBigLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            NSLayoutConstraint(item: logoBigLabel, attribute: .centerY, relatedBy: .equal,
                               toItem: view, attribute: .bottom, multiplier: 0.15, constant: 0.0),
            accountsContainterView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            accountsContainterView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            NSLayoutConstraint(item: accountsContainterView, attribute: .width, relatedBy: .equal,
                               toItem: view, attribute: .width, multiplier: 0.7, constant: 0.0),
            NSLayoutConstraint(item: accountsContainterView, attribute: .height, relatedBy: .equal,
                               toItem: view, attribute: .height, multiplier: 0.37, constant: 0.0)
        ])

        if savedAccounts.count == 0 {

            // No accounts saved
            accountsContainterView.addSubview(noAccountsLabel)
            accountsContainterView.addSubview(addAccountButton)

            NSLayoutConstraint.activate([
                signUpLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                signUpLabel.centerYAnchor.constraint(equalTo: view.bottomAnchor, constant: -view.bounds.height * 0.035),
                noAccountsLabel.centerXAnchor.constraint(equalTo: accountsContainterView.centerXAnchor),
                noAccountsLabel.centerYAnchor.constraint(equalTo: accountsContainterView.centerYAnchor),
                addAccountButton.centerYAnchor.constraint(equalTo: accountsContainterView.bottomAnchor, constant: -view.bounds.height * 0.025),
                addAccountButton.centerXAnchor.constraint(equalTo: accountsContainterView.centerXAnchor)
            ])

        } else {
            view.addSubview(loginToAnotherAccountButton)

            NSLayoutConstraint.activate([
                NSLayoutConstraint(item: signUpLabel, attribute: .centerX, relatedBy: .equal,
                                   toItem: view, attribute: .trailing, multiplier: 0.66, constant: 0.0),
                NSLayoutConstraint(item: loginToAnotherAccountButton, attribute: .centerX, relatedBy: .equal,
                                   toItem: view, attribute: .trailing, multiplier: 0.33, constant: 0.0),
                signUpLabel.centerYAnchor.constraint(equalTo: view.bottomAnchor, constant: -view.bounds.height * 0.035),
                loginToAnotherAccountButton.centerYAnchor.constraint(equalTo: view.bottomAnchor, constant: -view.bounds.height * 0.035)
            ])
        }
    }

    @objc fileprivate func handleLoginAction() {
        let controller = LoginViewController()
        controller.modalPresentationStyle = .formSheet

        controller.onCancel = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }

        controller.onSuccess = { [weak self] account, token in
            self?.dismiss(animated: true, completion: {

                guard let wself = self else { return }

                if wself.savedAccounts.contains(account) {
                    let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Window Title"),
                                                message: NSLocalizedString("Account already saved", comment: "Error Message"),
                                         preferredStyle: UIAlertControllerStyle.alert)
                    let actionOK = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
                    alert.addAction(actionOK)
                    wself.present(alert, animated: false, completion: nil)
                } else {
                    do {
                        try AppSecurity.save(token: token, account: account)
                        wself.savedAccounts.append(account)
                        wself.onSelect?()
                    } catch let error {
                        print(error.localizedDescription)
                    }
                }
            })
        }
        present(controller, animated: true, completion: nil)
    }

    @objc fileprivate func handleSelectedAccount(_ sender: UIButton) {

        let account = savedAccounts[sender.tag]
        DigiClient.shared.token = AppSecurity.getToken(account: account)
        AppSettings.accountLoggedIn = account
        self.onSelect?()
    }

    fileprivate func getSavedAccounts() {
        savedAccounts = UserDefaults.standard.array(forKey: "savedAccounts") as? [String] ?? []
    }
}
