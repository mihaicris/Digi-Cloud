//
//  ListingViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 19/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

#if DEBUG
var count: Int = 0
#endif

final class ListingViewController: UITableViewController {

    // MARK: - Properties
    var onFinish: (() -> Void)?
    fileprivate let action: ActionType
    fileprivate var location: Location
    fileprivate var needRefresh: Bool = true
    fileprivate var isUpdating: Bool = false
    fileprivate var content: [Node] = []
    fileprivate var filteredContent: [Node] = []
    fileprivate var currentIndex: IndexPath!
    fileprivate var searchController: UISearchController!
    fileprivate var fileCellID: String = ""
    fileprivate var folderCellID: String = ""

    fileprivate let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        f.locale = Locale.current
        f.dateFormat = "dd.MM.YYY・HH:mm"
        return f
    }()

    fileprivate let byteFormatter: ByteCountFormatter = {
        let f = ByteCountFormatter()
        f.countStyle = .binary
        f.allowsNonnumericFormatting = false
        return f
    }()

    fileprivate let busyIndicator: UIActivityIndicatorView = {
        let i = UIActivityIndicatorView()
        i.hidesWhenStopped = true
        i.activityIndicatorViewStyle = .gray
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()

    fileprivate let emptyFolderLabel: UILabel = {
        let l = UILabel()
        l.textColor = UIColor.lightGray
        l.textAlignment = .center
        return l
    }()

    fileprivate lazy var messageStackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.spacing = 10
        sv.alignment = .center
        sv.addArrangedSubview(self.busyIndicator)
        sv.addArrangedSubview(self.emptyFolderLabel)
        return sv
    }()

    fileprivate var searchButton, addFolderButton, sortButton: UIBarButtonItem!

    #if DEBUG
    let tag: Int
    #endif

    // MARK: - Initializers and Deinitializers

    init(action: ActionType, for location: Location) {
        self.action = action
        self.location = location
        #if DEBUG
            count += 1
            self.tag = count
            print(self.tag, "✅", String(describing: type(of: self)), action)
        #endif
        super.init(style: .plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    #if DEBUG
    deinit {
        print(self.tag, "❌", String(describing: type(of: self)), action)
        count -= 1
    }
    #endif

    // MARK: - Overridden Methods and Properties

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        if self.action == .noAction {
            updateRightBarButtonItems()
            tableView.tableHeaderView = nil
        }
        if needRefresh {
            content.removeAll()
            busyIndicator.startAnimating()
            emptyFolderLabel.text = NSLocalizedString("Loading ...", comment: "Information")
            tableView.reloadData()
        }
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        DigiClient.shared.task?.cancel()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        super.viewWillDisappear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if needRefresh {
            self.updateContent()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return content.isEmpty ? 2 : content.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if content.isEmpty {

            let cell = UITableViewCell()
            cell.isUserInteractionEnabled = false

            if indexPath.row == 1 {
                cell.contentView.addSubview(messageStackView)
                NSLayoutConstraint.activate([
                    messageStackView.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
                    messageStackView.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
                ])

            }
            return cell
        }

        let item = content[indexPath.row]

        if item.type == "dir" {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: folderCellID, for: indexPath) as? DirectoryCell else {
                return UITableViewCell()
            }
            cell.delegate = self

            cell.folderNameLabel.text = item.name

            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: fileCellID, for: indexPath) as? FileCell else {
                return UITableViewCell()
            }
            cell.delegate = self

            let modifiedDate = dateFormatter.string(from: Date(timeIntervalSince1970: item.modified / 1000))
            cell.fileNameLabel.text = item.name

            let fileSizeString = byteFormatter.string(fromByteCount: item.size) + "・" + modifiedDate
            cell.fileDetailsLabel.text = fileSizeString

            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: false)
        refreshControl?.endRefreshing()

        let item = content[indexPath.row]
        if item.type == "dir" {
            // This is a Folder

            let nextPath = self.location.path + item.name + "/"
            let nextLocation = Location(mount: self.location.mount, path: nextPath)

            let controller = ListingViewController(action: self.action, for: nextLocation)

            controller.title = item.name
            if self.action != .noAction {

                // It makes sens only if this is a copy or move controller
                controller.onFinish = { [unowned self] in
                    self.onFinish?()
                }
            }
            navigationController?.pushViewController(controller, animated: true)

        } else {

            // This is a file

            if self.action != .noAction {
                return
            }

            let nextPath = self.location.path + item.name
            let nextLocation = Location(mount: self.location.mount, path: nextPath)

            let controller = ContentViewController(location: nextLocation)
            controller.title = item.name
            navigationController?.pushViewController(controller, animated: true)
        }
    }

    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if refreshControl?.isRefreshing == true {
            if self.isUpdating {
                return
            }
            endRefreshAndReloadTable()
        }
    }

    // MARK: - Helper Methods

    fileprivate func setupTableView() {

        switch self.action {
        case .copy, .move:
            self.fileCellID = "FileCell"
            self.folderCellID = "DirectoryCell"
        default:
            self.fileCellID = "FileCellWithButton"
            self.folderCellID = "DirectoryCellWithButton"
            setupSearchController()
        }

        refreshControl = UIRefreshControl()
        setRefreshControlTitle(started: false)
        refreshControl?.addTarget(self, action: #selector(handleRefresh), for: UIControlEvents.valueChanged)

        tableView.register(FileCell.self, forCellReuseIdentifier: fileCellID)
        tableView.register(DirectoryCell.self, forCellReuseIdentifier: folderCellID)
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.rowHeight = AppSettings.tableViewRowHeight
        definesPresentationContext = true
    }

    fileprivate func setupViews() {
        switch self.action {
        case .copy, .move:
            self.navigationItem.prompt = NSLocalizedString("Choose a destination", comment: "Window prompt")

            let cancelButton = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: "Button Title"),
                                               style: .plain,
                                               target: self,
                                               action: #selector(handleDone))
            navigationItem.setRightBarButton(cancelButton, animated: false)
            navigationController?.isToolbarHidden = false

            let buttonTitle = self.action == .copy ?
                NSLocalizedString("Save copy", comment: "Button Title") :
                NSLocalizedString("Move", comment: "Button Title")

            let copyMoveButton = UIBarButtonItem(title: buttonTitle,
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(handleCopyOrMove))
            // TODO: Activate when source and destination paths are not the same
            copyMoveButton.isEnabled = true

            let toolBarItems = [
                UIBarButtonItem(title: NSLocalizedString("Create Folder", comment: "Button Title"),
                                style: .plain,
                                target: self,
                                action: #selector(handleCreateFolder)),
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                copyMoveButton
            ]
            setToolbarItems(toolBarItems, animated: false)
        default:
            break
        }
    }

    fileprivate func setupSearchController() {
        let src = SearchResultController(currentLocation: self.location)
        searchController = UISearchController(searchResultsController: src)
        searchController.delegate = self
        searchController.loadViewIfNeeded()
        searchController.searchResultsUpdater = src
        searchController.searchBar.delegate = src
        searchController.searchBar.autocorrectionType = .no
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.placeholder = NSLocalizedString("Search for files or folders", comment: "Action title")
        searchController.searchBar.scopeButtonTitles = [NSLocalizedString("This folder", comment: "Button title"),
                                                        NSLocalizedString("Everywhere", comment: "Button title")]
        searchController.searchBar.setValue(NSLocalizedString("Cancel", comment: "Button Title"), forKey: "cancelButtonText")
    }

    fileprivate func setRefreshControlTitle(started: Bool) {
        let title: String
        let attributes: [String: Any] = [NSFontAttributeName: UIFont(name: "Helvetica", size: 10) as Any,
                                         NSForegroundColorAttributeName: UIColor.init(white: 0.2, alpha: 1.0)as Any]
        if started {
            title = NSLocalizedString("Refreshing ...", comment: "Title")
        } else {
            title = NSLocalizedString("Pull to refresh this folder", comment: "Title")
        }
        refreshControl?.attributedTitle = NSAttributedString(string: title, attributes: attributes)
    }

    fileprivate func updateContent() {

        self.needRefresh = false
        self.isUpdating = true

        if self.refreshControl?.isRefreshing == true {
            messageStackView.removeFromSuperview()
        }

        DigiClient.shared.getContent(of: location) { receivedContent, error in
            self.isUpdating = false

            guard error == nil else {
                switch error! {
                case NetworkingError.wrongStatus(let message):
                    self.refreshControl?.endRefreshing()
                    self.emptyFolderLabel.text = message
                    self.content.removeAll()
                    self.tableView.reloadData()
                default:
                    print("Error: \(error!.localizedDescription)")
                }
                return
            }
            if var newContent = receivedContent {
                switch self.action {
                case .copy, .move:
                    // Only in move action, the moved node is not shown in the list.
                    guard let sourceNode = (self.presentingViewController as? MainNavigationController)?.source else {
                        print("Couldn't get the source node.")
                        return
                    }
                    if self.action == .move {
                        for (index, elem) in newContent.enumerated() {
                            if elem.name == sourceNode.name {
                                newContent.remove(at: index)
                                break
                            }
                        }
                    }
                    // While copy and move, we sort by name with folders shown first.
                    newContent.sort {
                        return $0.type == $1.type ? ($0.name.lowercased() < $1.name.lowercased()) : ($0.type < $1.type)
                    }
                    self.content = newContent
                // In normal case (.noAction) we just sort the content with the method saved by the user.
                default:
                    self.content = newContent
                    self.sortContent()
                }

                // In case the user pulled the table to refresh, reload table only if the user has finished dragging.
                if self.refreshControl?.isRefreshing == true {
                    if self.tableView.isDragging {
                        return
                    } else {
                        self.updateMessageForEmptyFolder()
                        self.endRefreshAndReloadTable()
                    }
                } else {
                    self.updateMessageForEmptyFolder()

                    // The content update is made while normal navigating through folders, in this case simply reload the table.
                    self.tableView.reloadData()
                }
            }
        }
    }

    fileprivate func updateMessageForEmptyFolder() {
        // For the case when the folder is empty, setting the message text on screen.
        if self.content.isEmpty {
            busyIndicator.stopAnimating()
            emptyFolderLabel.text = NSLocalizedString("Folder is Empty", comment: "Information")
        }
    }

    fileprivate func endRefreshAndReloadTable() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.refreshControl?.endRefreshing()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.updateMessageForEmptyFolder()
                self.tableView.reloadData()
                self.setRefreshControlTitle(started: false)
            }
        }
    }

    fileprivate func sortContent() {
        switch AppSettings.sortMethod {
        case .byName:        sortByName()
        case .byDate:        sortByDate()
        case .bySize:        sortBySize()
        case .byContentType: sortByContentType()
        }
    }

    fileprivate func animateActionButton(active: Bool) {
        guard let actionButton = (tableView.cellForRow(at: currentIndex) as? BaseListCell)?.actionButton else {
            return
        }
        let transform = active ? CGAffineTransform.init(rotationAngle: CGFloat(M_PI_2)) : CGAffineTransform.identity
        UIView.animate(withDuration: 0.4,
                       delay: 0.0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 1,
                       options: UIViewAnimationOptions.curveEaseOut,
                       animations: {
                          actionButton.transform = transform
                       },
                       completion: nil)
    }

    fileprivate func updateRightBarButtonItems() {

        var buttonTitle: String
        let isAscending = AppSettings.sortAscending

        switch AppSettings.sortMethod {
        case .byName:        buttonTitle = NSLocalizedString("Name", comment: "Button title") + (isAscending ? " ↑" : " ↓")
        case .byDate:        buttonTitle = NSLocalizedString("Date", comment: "Button title") + (isAscending ? " ↑" : " ↓")
        case .bySize:        buttonTitle = NSLocalizedString("Size", comment: "Button title") + (isAscending ? " ↑" : " ↓")
        case .byContentType: buttonTitle = NSLocalizedString("Type", comment: "Button title") + (isAscending ? " ↑" : " ↓")
        }
        sortButton      = UIBarButtonItem(title: buttonTitle, style: .plain, target: self, action: #selector(handleSortSelect))
        addFolderButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleCreateFolder))
        searchButton    = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(handleSearch))
        navigationItem.setRightBarButtonItems([sortButton, addFolderButton, searchButton], animated: false)
    }

    fileprivate func sortByName() {
        if AppSettings.showsFoldersFirst {
            if AppSettings.sortAscending {
                self.content.sort { return $0.type == $1.type ? ($0.name.lowercased() < $1.name.lowercased()) : ($0.type < $1.type) }
            } else {
                self.content.sort { return $0.type == $1.type ? ($0.name.lowercased() > $1.name.lowercased()) : ($0.type < $1.type) }
            }
        } else {
            if AppSettings.sortAscending {
                self.content.sort { return $0.name.lowercased() < $1.name.lowercased() }
            } else {
                self.content.sort { return $0.name.lowercased() > $1.name.lowercased() }
            }
        }
    }

    fileprivate func sortByDate() {
        if AppSettings.showsFoldersFirst {
            if AppSettings.sortAscending {
                self.content.sort { return $0.type == $1.type ? ($0.modified < $1.modified) : ($0.type < $1.type) }
            } else {
                self.content.sort { return $0.type == $1.type ? ($0.modified > $1.modified) : ($0.type < $1.type) }
            }
        } else {
            if AppSettings.sortAscending {
                self.content.sort { return $0.modified < $1.modified }
            } else {
                self.content.sort { return $0.modified > $1.modified }
            }
        }
    }

    fileprivate func sortBySize() {
        if AppSettings.sortAscending {
            self.content.sort { return $0.type == $1.type ? ($0.size < $1.size) : ($0.type < $1.type) }
        } else {
            self.content.sort { return $0.type == $1.type ? ($0.size > $1.size) : ($0.type < $1.type) }
        }
    }

    fileprivate func sortByContentType() {
        if AppSettings.sortAscending {
            self.content.sort { return $0.type == $1.type ? ($0.ext < $1.ext) : ($0.type < $1.type) }
        } else {
            self.content.sort { return $0.type == $1.type ? ($0.ext > $1.ext) : ($0.type < $1.type) }
        }
    }

    fileprivate func getIndexBeforeExtension(fileName: String) -> String.Index? {

        // file has an extension?
        let components = fileName.components(separatedBy: ".")

        guard components.count > 1 else {
            return nil
        }

        // yes, it has
        let fileExtension = components.last!

        // setting the cursor in the textField before the extension including the "."
        if let range = fileName.range(of: fileExtension) {
            return fileName.index(before: range.lowerBound)
        } else {
            return nil
        }

    }

    fileprivate func resetSearchViewControllerIndex() {
        if let nav = navigationController as? MainNavigationController {
            nav.searchResultsControllerIndex = nil
        }
    }

    fileprivate func setBusyIndicatorView(_ visible: Bool) {
        guard let navControllerView = navigationController?.view else {
            return
        }
        if visible {
            let screenSize = navControllerView.bounds.size
            let origin = CGPoint(x: (screenSize.width / 2) - 45, y: (screenSize.height / 2) - 45)
            let frame = CGRect(origin: origin, size: CGSize(width: 90, height: 90))
            let overlayView = UIView(frame: frame)
            overlayView.layer.cornerRadius = 8
            overlayView.backgroundColor = UIColor.init(white: 0.7, alpha: 0.8)
            overlayView.tag = 1
            navControllerView.addSubview(overlayView)

            let activityIndicator = UIActivityIndicatorView()
            activityIndicator.startAnimating()
            activityIndicator.activityIndicatorViewStyle = .white
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            navControllerView.addSubview(activityIndicator)

            NSLayoutConstraint.activate([
                activityIndicator.centerXAnchor.constraint(equalTo: navControllerView.centerXAnchor),
                activityIndicator.centerYAnchor.constraint(equalTo: navControllerView.centerYAnchor)
            ])

        } else {
            if let overlayView = navControllerView.viewWithTag(1) {
                overlayView.removeFromSuperview()
            }
        }
    }

    @objc fileprivate func handleSortSelect() {
        let controller = SortFolderViewController()
        controller.onFinish = { [unowned self](dismiss) in
            if dismiss {
                self.dismiss(animated: true, completion: nil)
            }
            self.sortContent()
            self.tableView.reloadData()
            self.updateRightBarButtonItems()
        }
        controller.modalPresentationStyle = .popover
        guard let buttonView = navigationItem.rightBarButtonItems?[0].value(forKey: "view") as? UIView else { return }
        controller.popoverPresentationController?.sourceView = buttonView
        controller.popoverPresentationController?.sourceRect = buttonView.bounds
        present(controller, animated: true, completion: nil)
    }

    @objc fileprivate func handleCreateFolder() {
        let controller = CreateFolderViewController(location: location)
        controller.onFinish = { [unowned self](folderName) in
            // dismiss AddFolderViewController
            self.dismiss(animated: true) {
                guard let folderName = folderName else {
                    // User cancelled the folder creation
                    return
                }
                let nextPath = self.location.path + folderName + "/"

                // Set needRefresh in this list
                self.needRefresh = true

                // Set needRefresh in the main List
                if let nav = self.presentingViewController as? UINavigationController {
                    if let cont = nav.topViewController as? ListingViewController {
                        cont.needRefresh = true
                    }
                }
                let folderLocation = Location(mount: self.location.mount, path: nextPath)

                let controller = ListingViewController(action: self.action, for: folderLocation)
                controller.title = folderName
                controller.onFinish = {[unowned self] in
                    self.onFinish?()
                }
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.modalPresentationStyle = .formSheet
        present(navigationController, animated: true, completion: nil)
    }

    @objc fileprivate func handleDone() {
        self.onFinish?()
    }

    @objc fileprivate func handleRefresh() {
        if self.isUpdating {
            self.refreshControl?.endRefreshing()
            return
        }
        setRefreshControlTitle(started: true)
        self.updateContent()
    }

    @objc fileprivate func handleSearch() {
        guard let nav = self.navigationController as? MainNavigationController else {
            print("Could not get the MainNavigationController")
            return
        }

        // If index of the search controller is set, and it is different than the current index on
        // navigation stack, then we pop to the saved index, otherwise we show the search controller.
        if let index = nav.searchResultsControllerIndex, index != nav.viewControllers.count - 1 {
            let searchResultsController = nav.viewControllers[index]
            _ = self.navigationController?.popToViewController(searchResultsController, animated: true)
        } else {
            nav.searchResultsControllerIndex = nav.viewControllers.count - 1
            self.tableView.setContentOffset(CGPoint(x: 0, y: -64), animated: false)
            if self.tableView.tableHeaderView == nil {
                searchController.searchBar.sizeToFit()
                self.tableView.tableHeaderView = searchController.searchBar
            }
            searchController.searchBar.becomeFirstResponder()
        }
    }

    @objc fileprivate func handleCopyOrMove() {

        setBusyIndicatorView(true)

        guard let sourceNode = (self.presentingViewController as? MainNavigationController)?.source else {
            print("Couldn't get the source node name.")
            return
        }

        var destinationLocation = Location(mount: self.location.mount, path: self.location.path + sourceNode.name)

        let index = getIndexBeforeExtension(fileName: sourceNode.name)

        if self.action == .copy {
            // TODO: Check if the content has already this name

            var destinationName = sourceNode.name

            var copyCount: Int = 0
            var wasRenamed = false
            var wasFound: Bool
            repeat {
                // reset before check of all nodes
                wasFound = false

                // check all nodes for the initial name or new name incremented
                for node in self.content {
                    if node.name == destinationName {
                        // set the flags
                        wasFound = true
                        wasRenamed = true

                        // increment counter in the new file name
                        copyCount += 1

                        // reset name to original
                        destinationName = sourceNode.name

                        // Pad number (using Foundation Method)
                        let countString = String(format: " (%d)", copyCount)

                        // If name has an extension, we introduce the count number
                        if index != nil {
                            destinationName.insert(contentsOf: countString.characters, at: index!)
                        } else {
                            destinationName = sourceNode.name + countString
                        }
                    }
                }
            } while (wasRenamed && wasFound)

            // change the file/folder name with incremented one
            destinationLocation = Location(mount: destinationLocation.mount, path: self.location.path + destinationName)
        }

        DigiClient.shared.copyOrMoveNode(action: self.action, from: sourceNode.location, to: destinationLocation) { statusCode, error in

            func setNeededRefreshInMain() {
                // Set needRefresh true in the main Listing controller
                if let nav = self.presentingViewController as? UINavigationController {
                    for controller in nav.viewControllers {
                        if let controller = controller as? ListingViewController {
                            controller.needRefresh = true
                        }
                    }
                }
            }

            self.setBusyIndicatorView(false)

            guard error == nil else {
                print(error!.localizedDescription)
                // TODO: Show error message and wait for dismiss
                return
            }

            if let code = statusCode {
                switch code {
                case 200:
                    // Operation successfully completed
                    setNeededRefreshInMain()
                    self.onFinish?()
                case 400:
                    // Bad request ( Folder already exists, invalid file name?)
                    // TODO: Show error message and wait for dismiss
                    print("Status Code 400 : Bad request")
                case 404:
                    // Not Found (Folder do not exists anymore), folder will refresh
                    print("Status Code 404 : Not found")
                    setNeededRefreshInMain()
                    self.onFinish?()
                default :
                    print("Server replied with Status Code: ", code)
                    // TODO: Show message and wait for dismiss
                }
            }
        }
    }
}

extension ListingViewController: UIPopoverPresentationControllerDelegate {
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        self.animateActionButton(active: false)
        return true
    }
}

extension ListingViewController: ActionViewControllerDelegate {
    func didSelectOption(action: ActionType) {

        self.animateActionButton(active: false)
        dismiss(animated: true) {
            let node: Node = self.content[self.currentIndex.row]

            switch action {
            case .rename:
                let controller = RenameViewController(location: self.location, node: node)
                controller.onFinish = { (newName, needRefresh) in
                    // dismiss RenameViewController
                    self.dismiss(animated: true) {
                        if newName != nil {
                            self.content[self.currentIndex.row] = Node(name: newName!, type: node.type,
                                                                       modified: node.modified, size: node.size,
                                                                       contentType: node.contentType, hash: node.hash,
                                                                       location: node.location)
                            self.tableView.reloadRows(at: [self.currentIndex], with: .middle)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                self.updateContent()
                            }
                        } else {
                            if needRefresh {
                                self.updateContent()
                            }
                        }
                    }
                }
                let navController = UINavigationController(rootViewController: controller)
                navController.modalPresentationStyle = .formSheet
                self.present(navController, animated: true, completion: nil)

            case .copy, .move:

                // Save the source node in the MainNavigationController
                (self.navigationController as? MainNavigationController)?.source = node

                guard let previousControllers = self.navigationController?.viewControllers else {
                    print("Couldn't get the previous navigation controllers!")
                    return
                }

                var controllers: [UIViewController] = []

                for (index, p) in previousControllers.enumerated() {

                    // If index is 0 than this is a location controller
                    if index == 0 {
                        let c = LocationsViewController(action: action)
                        c.title = NSLocalizedString("Locations", comment: "Window Title")
                        c.onFinish = { [unowned self] in

                            // Clear source node
                            (self.navigationController as? MainNavigationController)?.source = nil

                            self.dismiss(animated: true) {
                                if self.needRefresh {
                                    self.updateContent()
                                }
                            }
                        }
                        controllers.append(c)
                        continue
                    }

                    // we need to cast in order to tet the mountID and path from it
                    if let p = p as? ListingViewController {
                        let c = ListingViewController(action: action, for: p.location)
                        c.title = p.title
                        c.onFinish = { [unowned self] in
                            if self.action != .noAction {
                                self.onFinish?()
                            } else {
                                self.dismiss(animated: true) {

                                    // Clear source node
                                    (self.navigationController as? MainNavigationController)?.source = nil

                                    if self.needRefresh {
                                        self.updateContent()
                                    }
                                }
                            }
                        }
                        controllers.append(c)
                    }
                }

                let navController = UINavigationController(navigationBarClass: CustomNavBar.self, toolbarClass: nil)
                navController.setViewControllers(controllers, animated: false)
                navController.modalPresentationStyle = .formSheet
                self.present(navController, animated: true, completion: nil)

            case .delete:

                if node.type == "file" {
                    let controller = DeleteViewController(node: node)
                    controller.delegate = self

                    // position alert on the same row with the file
                    var sourceView = self.tableView.cellForRow(at: self.currentIndex)!.contentView
                    for view in sourceView.subviews {
                        if view.tag == 1 {
                            sourceView = view.subviews[0]
                        }
                    }
                    controller.modalPresentationStyle = .popover
                    controller.popoverPresentationController?.sourceView = sourceView
                    controller.popoverPresentationController?.sourceRect = sourceView.bounds
                    self.present(controller, animated: true, completion: nil)
                }

            case .folderInfo:
                let controller = FolderInfoViewController(location: self.location, node: node)
                controller.onFinish = { (success, needRefresh) in

                    // dismiss FolderViewController
                    self.dismiss(animated: true) {
                        if success {
                            self.content.remove(at: self.currentIndex.row)
                            if self.content.count == 0 {
                                self.updateMessageForEmptyFolder()
                                self.tableView.reloadData()
                            } else {
                                self.tableView.deleteRows(at: [self.currentIndex], with: .left)
                            }
                        } else {
                            if needRefresh {
                                self.updateContent()
                            }
                        }
                    }
                }
                let navController = UINavigationController(rootViewController: controller)
                navController.modalPresentationStyle = .formSheet
                self.present(navController, animated: true, completion: nil)

            default:
                return
            }
        }
    }
}

extension ListingViewController: BaseListCellDelegate {
    func showActionController(for sourceView: UIView) {
        let buttonPosition = sourceView.convert(CGPoint.zero, to: self.tableView)
        guard let indexPath = tableView.indexPathForRow(at: buttonPosition) else { return }

        self.currentIndex = indexPath
        self.animateActionButton(active: true)

        let controller = ActionViewController(node: self.content[indexPath.row])
        controller.delegate = self

        var sourceView = tableView.cellForRow(at: currentIndex)!.contentView
        for view in sourceView.subviews {
            if view.tag == 1 {
                sourceView = view.subviews[0]
            }
        }
        controller.modalPresentationStyle = .popover
        controller.popoverPresentationController?.sourceView = sourceView
        controller.popoverPresentationController?.sourceRect = sourceView.bounds
        controller.popoverPresentationController?.delegate = self
        present(controller, animated: true, completion: nil)
    }
}

extension ListingViewController: DeleteViewControllerDelegate {
    func onConfirmDeletion() {

        // Dismiss DeleteAlertViewController
        dismiss(animated: true) {
            let nodePath = self.location.path + self.content[self.currentIndex.row].name

            // network request for delete
            let deleteLocation = Location(mount: self.location.mount, path: nodePath)
            DigiClient.shared.deleteNode(at: deleteLocation) { statusCode, error in
                // TODO: Stop spinner
                guard error == nil else {
                    // TODO: Show message for error
                    print(error!.localizedDescription)
                    return
                }
                if let code = statusCode {
                    switch code {
                    case 200:
                        self.content.remove(at: self.currentIndex.row)
                        if self.content.isEmpty {
                            self.updateMessageForEmptyFolder()
                            self.tableView.reloadData()
                        } else {
                            self.tableView.deleteRows(at: [self.currentIndex], with: .left)
                        }
                    case 400:
                        self.updateContent()
                    case 404:
                        self.updateContent()
                    default :
                        break
                    }
                } else {
                    print("Error: could not obtain a status code")
                }
            }
        }
    }
}

extension ListingViewController: UISearchControllerDelegate {
    func willPresentSearchController(_ searchController: UISearchController) {
        DispatchQueue.main.async {
            searchController.searchResultsController?.view.isHidden = false
        }
    }

    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchResultsController?.view.isHidden = false
    }

    func willDismissSearchController(_ searchController: UISearchController) {
        guard let src = searchController.searchResultsController as? SearchResultController else {
            return
        }
        resetSearchViewControllerIndex()
        src.filteredContent.removeAll()
        src.tableView.reloadData()
    }
}
