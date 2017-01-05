//
//  AccountSelectionViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 03/01/17.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import UIKit

class AccountSelectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    // MARK: - Properties

    var onSelect: (() -> Void)?

    /// An array of logged users
    fileprivate var savedAccounts: [Account] = []

    // MARK: - Overridden Methods and Properties

    override func viewDidLoad() {
        super.viewDidLoad()
        getSavedUsers()
        setupViews()
    }

    // MARK: - Helper Functions

    fileprivate func setupViews() {
        collectionView?.backgroundColor = .green

        let label: UILabel = {
            let l = UILabel()
            l.text = "Account Selection"
            l.textColor = .white
            l.font = UIFont(name: "Helvetica", size: 48)
            l.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
            l.sizeToFit()
            l.center = view.center
            return l
        }()

        let button1: UIButton = {
            let b = UIButton(type: UIButtonType.system)
            b.setTitle(savedAccounts[0].username, for: .normal)
            b.tag = 0
            b.addTarget(self, action: #selector(handleSelectedAccount(_:)), for: UIControlEvents.touchUpInside)
            b.translatesAutoresizingMaskIntoConstraints = false
            return b
        }()

        let button2: UIButton = {
            let b = UIButton(type: UIButtonType.system)
            b.setTitle(savedAccounts[1].username, for: .normal)
            b.tag = 1
            b.addTarget(self, action: #selector(handleSelectedAccount(_:)), for: UIControlEvents.touchUpInside)
            b.translatesAutoresizingMaskIntoConstraints = false
            return b
        }()

        view.addSubview(label)
        view.addSubview(button1)
        view.addSubview(button2)

        NSLayoutConstraint.activate([
            button1.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 40),
            button1.centerXAnchor.constraint(equalTo: collectionView!.centerXAnchor),
            button2.topAnchor.constraint(equalTo: button1.bottomAnchor, constant: 40),
            button2.centerXAnchor.constraint(equalTo: collectionView!.centerXAnchor)
        ])
    }

    @objc fileprivate func handleSelectedAccount(_ sender: UIButton) {

        let account = savedAccounts[sender.tag].username
        DigiClient.shared.token = AppSecurity.getToken(account: account)
        AppSettings.accountLoggedIn = account
        self.onSelect?()
    }

    fileprivate func getSavedUsers() {

        /*
         TODO: Get this list from persisted protected source (Keychain Sharing).
         Temporary hardcoded data in file `Accounts.json` in main Bundle
         {
         "email_address": "<email_address>",
         "token": "<token>"
         }
         */

        let filePath = Bundle.main.path(forResource: "Accounts", ofType: "json")!
        let fileURL = URL(fileURLWithPath: filePath)
        let data = try! Data.init(contentsOf: fileURL)
        guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else {
            print("Eroare serializare JSON")
            return
        }
        guard let accountsDict = json as? [String: String] else {
            print("Eroare cast")
            return
        }
        for account in accountsDict {
            savedAccounts.append(Account(username: account.key, profileImage: nil))
        }
    }
}
