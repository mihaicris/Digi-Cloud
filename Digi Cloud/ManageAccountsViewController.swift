//
//  ManageAccountsViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 10/01/17.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import UIKit

class ManageAccountsViewController: UITableViewController {

    let cellId: String = "cellId"

    var accounts: [Account]

    init(accounts: [Account]) {
        self.accounts = accounts
        super.init(style: UITableViewStyle.plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(AccountTableViewCell.self, forCellReuseIdentifier: cellId)
        setupViews()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? AccountTableViewCell else {
            return UITableViewCell()
        }
        cell.account = accounts[indexPath.item]
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {

            guard let controller = navigationController?.presentingViewController as? AccountSelectionViewController else {
                return
            }

            let account = accounts[indexPath.row]
            do {
                try account.deleteItem()
                account.deleteProfileImageFromCache()
                accounts.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                if accounts.isEmpty {
                    dismiss(animated: true, completion: nil)
                }
                controller.fetchAccountsFromKeychain()
            } catch {
                fatalError("Error while deleting account from Keychain.")
            }
        }
    }

    fileprivate func setupViews() {
        preferredContentSize.height = 250
        preferredContentSize.width = 350
        title = NSLocalizedString("Accounts", comment: "Window Title")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(toggleEditMode))
    }

    @objc fileprivate func toggleEditMode() {
        var button: UIBarButtonItem
        if tableView.isEditing {
            button = UIBarButtonItem(title: NSLocalizedString("Edit", comment: "Button Title"),
                                     style: UIBarButtonItemStyle.plain,
                                     target: self,
                                     action: #selector(toggleEditMode))
        } else {
            button = UIBarButtonItem(title: NSLocalizedString("Done", comment: "Button Title"),
                                     style: UIBarButtonItemStyle.plain,
                                     target: self,
                                     action: #selector(toggleEditMode))
        }
        navigationItem.setRightBarButton(button, animated: false)
        tableView.isEditing = !tableView.isEditing
    }

}
