//
//  ManageBookmarksViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 06/03/2017.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import UIKit

final class ManageBookmarksViewController: UITableViewController {

    // MARK: - Properties

    private var mountsMapping: [String: Mount] = [:]

    private var bookmarks: [Bookmark] = []

    var onFinish: (() -> Void)?
    var onSelect: ((Location) -> Void)?
    var onUpdateNeeded: (() -> Void)?

    private let dispatchGroup = DispatchGroup()

    lazy var deleteButton: UIBarButtonItem = {
        let b = UIBarButtonItem(title: NSLocalizedString("Delete All", comment: ""), style: .done, target: self, action: #selector(handleAskDeleteConfirmation))
        return b
    }()

    lazy var cancelEditButton: UIBarButtonItem = {
        let b = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: ""), style: .done, target: self, action: #selector(handleCancelEdit))
        return b
    }()

    lazy var dismissButton: UIBarButtonItem = {
        let b = UIBarButtonItem(title: NSLocalizedString("Close", comment: ""), style: .done, target: self, action: #selector(handleDismiss))
        return b
    }()

    let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        ai.translatesAutoresizingMaskIntoConstraints = false
        ai.startAnimating()
        ai.hidesWhenStopped = true
        return ai
    }()

    let messageLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = .lightGray
        l.isHidden = true
        return l
    }()

    // MARK: - Initializers and Deinitializers

    init() {
        super.init(style: .plain)
        INITLog(self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        DEINITLog(self)
    }

    // MARK: - Overridden Methods and Properties

    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerForNotificationCenter()
        self.setupViews()
    }

    private func registerForNotificationCenter() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDismiss),
            name: .UIApplicationWillResignActive,
            object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateButtonsToMatchTableState()
        getBookmarksAndMounts()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookmarks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: BookmarkViewCell.self),
                                                       for: indexPath) as? BookmarkViewCell else {
            return UITableViewCell()
        }

        if let mountName = mountsMapping[bookmarks[indexPath.row].mountId]?.name {
            cell.bookmarkNameLabel.text = bookmarks[indexPath.row].name
            cell.pathLabel.text = mountName + String(bookmarks[indexPath.row].path.characters.dropLast())
        }

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

            let bookmark = bookmarks[indexPath.row]

            guard let mount = mountsMapping[bookmark.mountId] else {
                print("Mount for bookmark not found.")
                return
            }

            let location = Location(mount: mount, path: bookmark.path)

            dismiss(animated: true) {
                self.onSelect?(location)
            }
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteBookmarks(at: [indexPath])
        }
    }

    // MARK: - Helper Functions

    private func setupViews() {
        self.title = NSLocalizedString("Bookmarks", comment: "")

        tableView.register(BookmarkViewCell.self, forCellReuseIdentifier: String(describing: BookmarkViewCell.self))
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        tableView.rowHeight = AppSettings.tableViewRowHeight

        view.addSubview(activityIndicator)
        view.addSubview(messageLabel)

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40)
        ])
    }

    private func updateButtonsToMatchTableState() {
        if self.tableView.isEditing {
            self.navigationItem.rightBarButtonItem = self.cancelEditButton
            self.updateDeleteButtonTitle()
            self.navigationItem.leftBarButtonItem = self.deleteButton
        } else {
            // Not in editing mode.
            self.navigationItem.leftBarButtonItem = dismissButton
            if bookmarks.count != 0 {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(
                    title: NSLocalizedString("Edit", comment: ""),
                    style: .done,
                    target: self,
                    action: #selector(handleEnterEditMode))
            }
        }
    }

    private func updateDeleteButtonTitle() {
        var newTitle = NSLocalizedString("Delete All", comment: "")
        if let indexPathsForSelectedRows = self.tableView.indexPathsForSelectedRows {
            if indexPathsForSelectedRows.count != bookmarks.count {
                let titleFormatString = NSLocalizedString("Delete (%d)", comment: "")
                newTitle =  String(format: titleFormatString, indexPathsForSelectedRows.count)
            }
        }
        UIView.performWithoutAnimation {
            self.deleteButton.title = newTitle
        }
    }

    private func getBookmarksAndMounts() {

        var resultBookmarks: [Bookmark] = []
        var resultMounts: [Mount] = []

        var hasFetchedSuccessfully = true

        // Get the bookmarks
        dispatchGroup.enter()

        DigiClient.shared.getBookmarks { result, error in

            self.dispatchGroup.leave()

            guard error == nil, result != nil else {
                hasFetchedSuccessfully = false
                LogNSError(error! as NSError)
                return
            }

            resultBookmarks = result!
        }

        // Get the mounts
        dispatchGroup.enter()

        DigiClient.shared.getMounts { result, error in

            self.dispatchGroup.leave()

            guard error == nil, result != nil else {
                hasFetchedSuccessfully = false
                LogNSError(error! as NSError)
                return
            }

            resultMounts = result!
        }

        // Create dictionary with mountId: Mount
        dispatchGroup.notify(queue: .main) {

            self.activityIndicator.stopAnimating()

            if hasFetchedSuccessfully {

                let mountsIDs = resultMounts.map { $0.id }

                for bookmark in resultBookmarks.enumerated().reversed() {

                    if !mountsIDs.contains(bookmark.element.mountId) {
                        resultBookmarks.remove(at: bookmark.offset)
                    }
                }

                for mount in resultMounts {
                    self.mountsMapping[mount.id] = mount
                }

                self.bookmarks = resultBookmarks

                if self.bookmarks.count == 0 {
                    self.messageLabel.text = NSLocalizedString("No bookmarks", comment: "")
                    self.messageLabel.isHidden = false
                    return
                }

                self.tableView.reloadData()
                self.updateButtonsToMatchTableState()
            } else {
                self.messageLabel.text = NSLocalizedString("Error on fetching bookmarks", comment: "")
                self.messageLabel.isHidden = false
            }
        }
    }

    private func deleteBookmarks(at indexPaths: [IndexPath]) {

        var newBookmarks = bookmarks

        for indexPath in indexPaths.reversed() {
            newBookmarks.remove(at: indexPath.row)
        }

        // TODO: Start Activity Indicator

        DigiClient.shared.setBookmarks(bookmarks: newBookmarks) { error in

            // TODO: Stop Activity Indicator
            guard error == nil else {

                // TODO: Show error to user
                LogNSError(error! as NSError)
                return
            }

            // Success:
            self.bookmarks = newBookmarks
            self.tableView.deleteRows(at: indexPaths, with: .fade)

            if self.bookmarks.count == 0 {

                self.dismiss(animated: true) {
                    self.onFinish?()
                }

            } else {
                // Update main list
                self.onUpdateNeeded?()

                if self.tableView.isEditing {
                    self.handleToogleEditMode()
                    self.updateButtonsToMatchTableState()
                }
            }
        }
    }

    @objc private func handleDeleteSelectedBookmarks(_ action: UIAlertAction) {

        var indexPaths: [IndexPath] = []

        if let indexPathsForSelectedRows = tableView.indexPathsForSelectedRows {

            // Some or all rows selected
            indexPaths = indexPathsForSelectedRows

        } else {

            // No rows selected, means all rows.
            for (index, _ ) in bookmarks.enumerated() {
                indexPaths.append(IndexPath(row: index, section: 0))
            }
        }
        deleteBookmarks(at: indexPaths)
    }

    @objc private func handleToogleEditMode() {
        var button: UIBarButtonItem
        if tableView.isEditing {
            button = UIBarButtonItem(title: NSLocalizedString("Edit", comment: ""),
                                     style: UIBarButtonItemStyle.plain,
                                     target: self,
                                     action: #selector(handleToogleEditMode))
        } else {
            button = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""),
                                     style: UIBarButtonItemStyle.plain,
                                     target: self,
                                     action: #selector(handleToogleEditMode))
        }
        navigationItem.setRightBarButton(button, animated: false)
        tableView.setEditing(!tableView.isEditing, animated: true)
    }

    @objc private func handleEnterEditMode() {
        self.tableView.setEditing(true, animated: true)
        self.updateButtonsToMatchTableState()
    }

    @objc private func handleAskDeleteConfirmation() {

        var messageString: String

        if self.tableView.indexPathsForSelectedRows?.count == 1 {
            messageString = NSLocalizedString("Are you sure you want to remove this bookmark?", comment: "")
        } else {
            messageString = NSLocalizedString("Are you sure you want to remove these bookmarks?", comment: "")
        }

        let alertController = UIAlertController(title: NSLocalizedString("Delete confirmation", comment: ""),
                                                message: messageString,
                                                preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""),
                                         style: .cancel,
                                         handler: nil)

        let okAction = UIAlertAction(title: NSLocalizedString("Yes", comment: ""),
                                     style: .destructive,
                                     handler: handleDeleteSelectedBookmarks)

        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

    @objc private func handleCancelEdit() {
        self.tableView.setEditing(false, animated: true)
        self.updateButtonsToMatchTableState()
    }

    @objc private func handleDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
}
