//
//  ManageAccountsViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 10/01/17.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import UIKit

class ManageAccountsViewController: UITableViewController {

    // MARK: - Properties

    let cellId: String = "cellId"

    var accounts: [Account]

    var onAddAccount: (() -> Void)?
    var onFinish: (() -> Void)?

    let controller: AccountSelectionViewController

    lazy var addButton: UIBarButtonItem = {
        let b = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAction))
        return b
    }()

    lazy var editButton: UIBarButtonItem = {
        let b = UIBarButtonItem(title: NSLocalizedString("Edit", comment: "Button Title"), style: .plain, target: self, action: #selector(editAction))
        return b
    }()

    lazy var deleteButton: UIBarButtonItem = {
        let b = UIBarButtonItem(title: NSLocalizedString("Delete All", comment: "Button Title"), style: .plain, target: self, action: #selector(deleteAction))
        return b
    }()

    lazy var cancelButton: UIBarButtonItem = {
        let b = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: "Button Title"), style: .plain, target: self, action: #selector(cancelAction))
        return b
    }()

    // MARK: - Initializers and Deinitializers

    init(controller: AccountSelectionViewController, accounts: [Account]) {
        self.accounts = accounts
        self.controller = controller
        super.init(style: UITableViewStyle.plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overridden Methods and Properties

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(AccountTableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.allowsMultipleSelectionDuringEditing = true
        setupViews()
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
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

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.updateDeleteButtonTitle()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.updateButtonsToMatchTableState()
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {

            self.wipeAccount(at: indexPath)

            // If no accounts are stored in the model, the manage window is dismissed
            if accounts.isEmpty {
                self.onFinish?()
            }
        }
    }

    // MARK: - Helper Functions

    private func setupViews() {
        preferredContentSize.height = 400
        preferredContentSize.width = 350
        title = NSLocalizedString("Accounts", comment: "Window Title")

        updateButtonsToMatchTableState()
    }

    private func wipeAccount(at indexPath: IndexPath) {

        let account = accounts[indexPath.row]

        do {
            // Revoke the token
            account.revokeToken()

            // Delete profile image from local storage
            account.deleteProfileImageFromCache()

            // Delete account (token) from Keychain
            try account.deleteItem()

            // Delete account from the models
            self.accounts.remove(at: indexPath.row)
            controller.accounts.remove(at: indexPath.row)

            // Delete account on screen
            tableView.deleteRows(at: [indexPath], with: .fade)
            controller.accountsCollectionView.deleteItems(at: [indexPath])

        } catch {
            fatalError("Error while deleting account from Keychain.")
        }

    }

    private func updateButtonsToMatchTableState() {
        if (self.tableView.isEditing) {
            self.navigationItem.rightBarButtonItem = self.cancelButton
            self.updateDeleteButtonTitle()
            self.navigationItem.leftBarButtonItem = self.deleteButton
        } else {
            // Not in editing mode.
            self.navigationItem.leftBarButtonItem = self.addButton
            self.navigationItem.rightBarButtonItem = self.editButton
        }
    }

    private func updateDeleteButtonTitle() {
        if let selectedRows = self.tableView.indexPathsForSelectedRows {
            if selectedRows.count != accounts.count {
                let titleFormatString = NSLocalizedString("Delete (%d)", comment: "Button Title")
                self.deleteButton.title = String(format: titleFormatString, selectedRows.count)
                return
            }
        }
        self.deleteButton.title = NSLocalizedString("Delete All", comment: "Button Title")
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

    @objc private func addAction() {
        dismiss(animated: true) {
            self.onAddAccount?()
        }
    }

    @objc private func editAction() {
        self.tableView.setEditing(true, animated: true)
        self.updateButtonsToMatchTableState()
    }

    @objc private func deleteAction() {

        var messageString: String
        if self.tableView.indexPathsForSelectedRows?.count == 1 {
            messageString = NSLocalizedString("Are you sure you want to remove this account?", comment: "")
        } else {
            messageString = NSLocalizedString("Are you sure you want to remove these accounts?", comment: "")
        }

        let alertController = UIAlertController(title: NSLocalizedString("Confirm Deletion", comment: "Alert Title"),
                                                message: messageString,
                                                preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Action Title"),
                                         style: .cancel,
                                         handler: nil)

        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "Action Title"),
                                         style: .destructive,
                                         handler: deleteConfirmed)

        alertController.addAction(cancelAction)
        alertController.addAction(okAction)

        present(alertController, animated: true, completion: nil)
        return

    }

    @objc private func deleteConfirmed(_ action: UIAlertAction) {

        if let selectedRows = self.tableView.indexPathsForSelectedRows?.reversed(), selectedRows.count != accounts.count {

            self.tableView.beginUpdates()

            for selectedIndex in selectedRows {
                wipeAccount(at: selectedIndex)
            }

            // Table view is animating the deletions
            self.tableView.endUpdates()

        } else {
            // Delete all accounts
            for account in accounts {
                do {
                    // Revoke the token
                    account.revokeToken()

                    // Delete the account token from Keychain
                    try account.deleteItem()

                } catch {
                    fatalError("Error while deleting account from Keychain.")
                }

                // Delete all profile images
                FileManager.deleteProfileImagesCacheDirectory()
                FileManager.createProfileImagesCacheDirectory()

                // Dimiss the Login controller after all accounts have been removed
                self.onFinish?()
            }
        }
        self.tableView.setEditing(false, animated: true)
        self.updateButtonsToMatchTableState()

        controller.fetchAccountsFromKeychain()
        controller.accountsCollectionView.reloadData()
    }

    @objc private func cancelAction() {
        self.tableView.setEditing(false, animated: true)
        self.updateButtonsToMatchTableState()
    }
}
