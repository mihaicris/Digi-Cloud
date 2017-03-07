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
    var onUpdate: (() -> Void)?

    private let dispatchGroup = DispatchGroup()

    lazy var editButton: UIBarButtonItem = {
        let b = UIBarButtonItem(title: NSLocalizedString("Edit", comment: ""), style: .plain, target: self, action: #selector(handleEnterEditMode))
        return b
    }()
    
    lazy var deleteButton: UIBarButtonItem = {
        let b = UIBarButtonItem(title: NSLocalizedString("Delete All", comment: ""), style: .plain, target: self, action: #selector(handleAskDeleteConfirmation))
        return b
    }()
    
    lazy var cancelButton: UIBarButtonItem = {
        let b = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: ""), style: .plain, target: self, action: #selector(handleCancelEdit))
        return b
    }()
    
    // MARK: - Initializers and Deinitializers

    init() {
        super.init(style: .plain)
        INITLog(self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit { DEINITLog(self) }
    
    // MARK: - Overridden Methods and Properties
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(BookmarkViewCell.self, forCellReuseIdentifier: String(describing: BookmarkViewCell.self))
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        self.preferredContentSize.height = 0.01
        self.title = NSLocalizedString("Bookmarks", comment: "")
        getBookmarksAndMounts()
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookmarks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: BookmarkViewCell.self), for: indexPath) as? BookmarkViewCell else {
            return UITableViewCell()
        }
        
        if let mountName = mountsMapping[bookmarks[indexPath.row].mountId]?.name {
            cell.nameLabel.text = bookmarks[indexPath.row].name
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
           
            onSelect?(location)
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteBookmarks(at: [indexPath])
        }
    }
    
    // MARK: - Helper Functions

    private func updateButtonsToMatchTableState() {
        if self.tableView.isEditing {
            self.navigationItem.rightBarButtonItem = self.cancelButton
            self.updateDeleteButtonTitle()
            self.navigationItem.leftBarButtonItem = self.deleteButton
        } else {
            // Not in editing mode.
            if bookmarks.count != 0 {
                self.navigationItem.rightBarButtonItem = self.editButton
            }
            self.navigationItem.leftBarButtonItem = nil
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

            if hasFetchedSuccessfully {
                
                if resultBookmarks.count == 0 || resultMounts.count == 0 {
                    self.title = NSLocalizedString("No bookmarks", comment: "")
                    return
                }
                
                for mount in resultMounts {
                    self.mountsMapping[mount.id] = mount
                }
                self.bookmarks = resultBookmarks
                self.tableView.reloadData()
                self.updateButtonsToMatchTableState()
                self.preferredContentSize.height = 450
            } else {
                self.title = NSLocalizedString("Error on fetching bookmarks", comment: "")
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
                // Dismiss
                self.onFinish?()
            } else {
                // Update main list
                self.onUpdate?()
                
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
        
        let alertController = UIAlertController(title: NSLocalizedString("Confirm Deletion", comment: ""),
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

}
