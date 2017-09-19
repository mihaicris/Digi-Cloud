//
//  ManageAccountsViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 10/01/17.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import UIKit

final class ManageAccountsViewController: UITableViewController {

    // MARK: - Properties

    var users: [User] = []

    var onAddAccount: (() -> Void)?
    var onFinish: (() -> Void)?

    let controller: AccountSelectionViewController

    lazy var addButton: UIBarButtonItem = {
        let b = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAction))
        return b
    }()

    lazy var editButton: UIBarButtonItem = {
        let b = UIBarButtonItem(title: NSLocalizedString("Edit", comment: ""), style: .done, target: self, action: #selector(handleEnterEditMode))
        return b
    }()

    lazy var deleteButton: UIBarButtonItem = {
        let b = UIBarButtonItem(title: NSLocalizedString("Delete All", comment: ""), style: .done, target: self, action: #selector(handleAskDeleteConfirmation))
        return b
    }()

    lazy var cancelButton: UIBarButtonItem = {
        let b = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: ""), style: .done, target: self, action: #selector(handleCancelEdit))
        return b
    }()

    // MARK: - Initializers and Deinitializers

    init(controller: AccountSelectionViewController) {
        self.controller = controller
        self.users = controller.users
        super.init(style: UITableViewStyle.plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Overridden Methods and Properties

    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerForNotificationCenter()
        setupViews()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AccountTableViewCell.self),
                                                       for: indexPath) as? AccountTableViewCell else {
            return UITableViewCell()
        }
        cell.user = users[indexPath.item]
        return cell
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.updateDeleteButtonTitle()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            self.updateButtonsToMatchTableState()
        } else {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            self.wipeAccount(atIndexPath: indexPath)
            controller.users = self.users
            controller.configureViews()
            controller.collectionView.reloadData()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.dismissIfNoMoreUsers()
            }
        }
    }

    // MARK: - Helper Functions

    private func registerForNotificationCenter() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDismiss),
            name: .UIApplicationDidEnterBackground,
            object: nil)
    }

    private func setupViews() {
        preferredContentSize.width = 350
        preferredContentSize.height = tableView.contentSize.height - 1
        title = NSLocalizedString("Accounts", comment: "")
        tableView.register(AccountTableViewCell.self, forCellReuseIdentifier: String(describing: AccountTableViewCell.self))
        tableView.allowsMultipleSelectionDuringEditing = true
        updateButtonsToMatchTableState()
    }

    private func dismissIfNoMoreUsers() {
        // If no accounts are stored in the model, the manage window is dismissed
        if users.isEmpty {
            self.dismiss(animated: true) {
                self.onFinish?()
            }
        }
    }

    private func wipeAccount(atIndexPath indexPath: IndexPath) {

        let user = users[indexPath.row]

        let account = Account(userID: user.id)

        // Revoke the token
        account.revokeToken()

        // Delete profile image from local storage
        account.deleteProfileImageFromCache()

        // Delete the account info (name) from User defaults
        AppSettings.deletePersistedUserInfo(userID: user.id)

        // Delete user from the model
        self.users.remove(at: indexPath.row)

        // Delete user from the parent controller model
        controller.users.remove(at: indexPath.row)

        // Delete user from manage users list table
        tableView.deleteRows(at: [indexPath], with: .fade)

        // Delete user from parent users list table
        controller.collectionView.deleteItems(at: [indexPath])

        do {
            // Delete account token from Keychain
            try account.deleteItem()
        } catch {
            AppSettings.showErrorMessageAndCrash(
                title: NSLocalizedString("Error deleting account from Keychain", comment: ""),
                subtitle: NSLocalizedString("The app will now close", comment: "")
            )
        }

    }

    private func updateButtonsToMatchTableState() {
        if self.tableView.isEditing {
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
        var newTitle = NSLocalizedString("Delete All", comment: "")
        if let selectedRows = self.tableView.indexPathsForSelectedRows {
            if selectedRows.count != users.count {
                let titleFormatString = NSLocalizedString("Delete (%d)", comment: "")
                newTitle = String(format: titleFormatString, selectedRows.count)
            }
        }
        UIView.performWithoutAnimation {
            self.deleteButton.title = newTitle
        }
    }

    @objc private func handleToggleEditMode() {
        var button: UIBarButtonItem
        if tableView.isEditing {
            button = UIBarButtonItem(title: NSLocalizedString("Edit", comment: ""),
                                     style: UIBarButtonItemStyle.plain,
                                     target: self,
                                     action: #selector(handleToggleEditMode))
        } else {
            button = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""),
                                     style: UIBarButtonItemStyle.plain,
                                     target: self,
                                     action: #selector(handleToggleEditMode))
        }
        navigationItem.setRightBarButton(button, animated: false)
        tableView.setEditing(!tableView.isEditing, animated: true)
    }

    @objc private func addAction() {
        dismiss(animated: true) {
            self.onAddAccount?()
        }
    }

    @objc private func handleEnterEditMode() {
        self.tableView.setEditing(true, animated: true)
        self.updateButtonsToMatchTableState()
    }

    @objc private func handleAskDeleteConfirmation() {

        var messageString: String
        if self.tableView.indexPathsForSelectedRows?.count == 1 {
            messageString = NSLocalizedString("Are you sure you want to remove this account?", comment: "")
        } else {
            messageString = NSLocalizedString("Are you sure you want to remove these accounts?", comment: "")
        }

        let alertController = UIAlertController(title: NSLocalizedString("Delete confirmation", comment: ""),
                                                message: messageString,
                                                preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""),
                                         style: .cancel,
                                         handler: nil)

        let okAction = UIAlertAction(title: NSLocalizedString("Yes", comment: ""),
                                         style: .destructive,
                                         handler: deleteConfirmed)

        alertController.addAction(cancelAction)
        alertController.addAction(okAction)

        present(alertController, animated: true, completion: nil)
    }

    @objc private func deleteConfirmed(_ action: UIAlertAction) {

        if let selectedRows = self.tableView.indexPathsForSelectedRows?.reversed(), selectedRows.count != users.count {

            self.tableView.beginUpdates()

            for selectedIndex in selectedRows {
                wipeAccount(atIndexPath: selectedIndex)
            }

            // Table view is animating the deletions
            self.tableView.endUpdates()

        } else {

            self.tableView.beginUpdates()

            // Delete all accounts
            for (index, _) in users.enumerated().reversed() {

                let indexPath = IndexPath(row: index, section: 0)

                wipeAccount(atIndexPath: indexPath)
            }

            self.tableView.endUpdates()

            precondition(users.count == 0, "Not all users have been deleted!")

        }

        self.tableView.setEditing(false, animated: true)
        self.updateButtonsToMatchTableState()

        controller.users = self.users
        controller.configureViews()
        controller.collectionView.reloadData()

        dismissIfNoMoreUsers()
    }

    @objc private func handleDismiss() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc private func handleCancelEdit() {
        self.tableView.setEditing(false, animated: true)
        self.updateButtonsToMatchTableState()
    }
}
