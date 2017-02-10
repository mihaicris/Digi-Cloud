//
//  ListingViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 19/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

#if DEBUG_CONTROLLERS
var count: Int = 0
var taskStarted: Int = 0
var taskFinished: Int = 0
#endif

final class ListingViewController: UITableViewController {

    // MARK: - Properties
    var onFinish: (() -> Void)?
    fileprivate let editaction: ActionType
    fileprivate var location: Location
    fileprivate var needRefresh: Bool = true
    private var isUpdating: Bool = false
    private var isActionConfirmed: Bool = false
    fileprivate var content: [Node] = []
    private var filteredContent: [Node] = []
    fileprivate var currentIndex: IndexPath!
    private var searchController: UISearchController!
    private var fileCellID = String()
    private var folderCellID = String()
    private let dispatchGroup = DispatchGroup()
    private var didReceivedNetworkError = false
    private var didReceivedStatus400 = false
    private var didReceivedStatus404 = false
    private var didSucceedCopyOrMove = false

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        f.locale = Locale.current
        f.dateFormat = "dd.MM.YYY・HH:mm"
        return f
    }()

    private let byteFormatter: ByteCountFormatter = {
        let f = ByteCountFormatter()
        f.countStyle = .binary
        f.allowsNonnumericFormatting = false
        return f
    }()

    private let busyIndicator: UIActivityIndicatorView = {
        let i = UIActivityIndicatorView()
        i.hidesWhenStopped = true
        i.activityIndicatorViewStyle = .gray
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()

    private let emptyFolderLabel: UILabel = {
        let l = UILabel()
        l.textColor = UIColor.lightGray
        l.textAlignment = .center
        return l
    }()

    private lazy var messageStackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.spacing = 10
        sv.alignment = .center
        sv.addArrangedSubview(self.busyIndicator)
        sv.addArrangedSubview(self.emptyFolderLabel)
        return sv
    }()

    private var sortBarButton: UIBarButtonItem!

    private lazy var moreActionsBarButton: UIBarButtonItem = {
        let b = UIBarButtonItem(title: "⚬⚬⚬", style: .plain, target: self, action: #selector(handleShowMoreActions))
        return b
    }()

    private lazy var searchBarButton: UIBarButtonItem = {
        let b = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(handleSearch))
        return b
    }()

    private let flexibleBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

    private lazy var createFolderBarButton: UIBarButtonItem = {
        let b = UIBarButtonItem(title: NSLocalizedString("Create Directory", comment: ""), style: .plain, target: self, action: #selector(handleCreateDirectory))
        return b
    }()

    private lazy var copyInEditModeButton: UIBarButtonItem = {
        let b = UIBarButtonItem(title: NSLocalizedString("Copy", comment: ""), style: .plain, target: self, action: #selector(handleMultipleItemsEdit(_:)))
        b.tag = ActionType.copy.rawValue
        return b
    }()

    private lazy var moveInEditModeButton: UIBarButtonItem = {
        let b = UIBarButtonItem(title: NSLocalizedString("Move", comment: ""), style: .plain, target: self, action: #selector(handleMultipleItemsEdit(_:)))
        b.tag = ActionType.move.rawValue
        return b
    }()

    private lazy var deleteInEditModeButton: UIBarButtonItem = {
        let v = UIButton(type: UIButtonType.system)
        v.setTitle(NSLocalizedString("Delete", comment: ""), for: .normal)
        v.addTarget(self, action: #selector(handleMultipleItemsEdit(_:)), for: .touchUpInside)
        v.setTitleColor(UIColor(white: 0.8, alpha: 1), for: .disabled)
        v.setTitleColor(.red, for: .normal)
        v.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        v.sizeToFit()
        v.tag = ActionType.delete.rawValue
        let b = UIBarButtonItem(customView: v)
        return b
    }()

    private lazy var cancelInEditModeButton: UIBarButtonItem = {
        let b = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: ""), style: .plain, target: self, action: #selector(cancelEditMode))
        return b
    }()

    #if DEBUG_CONTROLLERS
    let tag: Int
    #endif

    // MARK: - Initializers and Deinitializers

    init(editaction: ActionType, for location: Location) {
        self.editaction = editaction
        self.location = location
        #if DEBUG_CONTROLLERS
            count += 1
            self.tag = count
            print(self.tag, "✅", String(describing: type(of: self)), editaction)
        #endif
        super.init(style: .plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    #if DEBUG_CONTROLLERS
    deinit {
        print(self.tag, "❌", String(describing: type(of: self)), editaction)
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
        if self.editaction == .noAction {
            updateNavigationBarRightButtonItems()
            tableView.tableHeaderView = nil
        }
        if needRefresh {
            content.removeAll()
            busyIndicator.startAnimating()
            emptyFolderLabel.text = NSLocalizedString("Loading ...", comment: "")
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
            cell.hasButton = !tableView.isEditing

            cell.folderNameLabel.text = item.name
            return cell

        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: fileCellID, for: indexPath) as? FileCell else {
                return UITableViewCell()
            }

            cell.delegate = self
            cell.hasButton = !tableView.isEditing

            let modifiedDate = dateFormatter.string(from: Date(timeIntervalSince1970: item.modified / 1000))
            cell.fileNameLabel.text = item.name

            let fileSizeString = byteFormatter.string(fromByteCount: item.size) + "・" + modifiedDate
            cell.fileDetailsLabel.text = fileSizeString

            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            updateToolBarButtonItemsToMatchTableState()
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if tableView.isEditing {
            updateToolBarButtonItemsToMatchTableState()
            return
        }

        tableView.deselectRow(at: indexPath, animated: false)
        refreshControl?.endRefreshing()

        let item = content[indexPath.row]
        if item.type == "dir" {
            // This is a Folder

            let nextPath = self.location.path + item.name + "/"
            let nextLocation = Location(mount: self.location.mount, path: nextPath)

            let controller = ListingViewController(editaction: self.editaction, for: nextLocation)

            controller.title = item.name
            if self.editaction != .noAction {

                // It makes sens only if this is a copy or move controller
                controller.onFinish = { [unowned self] in
                    self.onFinish?()
                }
            }
            navigationController?.pushViewController(controller, animated: true)

        } else {

            // This is a file

            if self.editaction != .noAction {
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

    private func setupTableView() {

        switch self.editaction {
        case .copy, .move:
            self.fileCellID = "FileCell"
            self.folderCellID = "DirectoryCell"
        default:
            self.fileCellID = "FileCellWithButton"
            self.folderCellID = "DirectoryCellWithButton"
            setupSearchController()
            definesPresentationContext = true
            tableView.allowsMultipleSelectionDuringEditing = true
        }

        refreshControl = UIRefreshControl()
        setRefreshControlTitle(started: false)
        refreshControl?.addTarget(self, action: #selector(handleRefresh), for: UIControlEvents.valueChanged)

        tableView.register(FileCell.self, forCellReuseIdentifier: fileCellID)
        tableView.register(DirectoryCell.self, forCellReuseIdentifier: folderCellID)
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.rowHeight = AppSettings.tableViewRowHeight

    }

    private func setupViews() {
        switch self.editaction {
        case .copy, .move:
            self.navigationItem.prompt = NSLocalizedString("Choose a destination", comment: "")

            let cancelButton = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: ""),
                                               style: .plain, target: self, action: #selector(handleDone))

            navigationItem.rightBarButtonItem = cancelButton

            navigationController?.isToolbarHidden = false

            let buttonTitle = self.editaction == .copy ?
                NSLocalizedString("Save copy", comment: "") :
                NSLocalizedString("Move", comment: "")

            let copyMoveButton = UIBarButtonItem(title: buttonTitle, style: .plain, target: self, action: #selector(handleCopyOrMove))
            copyMoveButton.isEnabled = true

            self.toolbarItems = [createFolderBarButton, flexibleBarButton, copyMoveButton]
        default:
            self.toolbarItems = [deleteInEditModeButton, flexibleBarButton, copyInEditModeButton, flexibleBarButton, moveInEditModeButton]
        }
    }

    private func setupSearchController() {
        let src = SearchResultController(currentLocation: self.location)
        searchController = UISearchController(searchResultsController: src)
        searchController.delegate = self
        searchController.loadViewIfNeeded()
        searchController.searchResultsUpdater = src
        searchController.searchBar.delegate = src
        searchController.searchBar.autocorrectionType = .no
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.placeholder = NSLocalizedString("Search for files or directories", comment: "")
        searchController.searchBar.scopeButtonTitles = [NSLocalizedString("This directory", comment: ""),
                                                        NSLocalizedString("Everywhere", comment: "")]
        searchController.searchBar.setValue(NSLocalizedString("Cancel", comment: ""), forKey: "cancelButtonText")
    }

    private func setRefreshControlTitle(started: Bool) {
        let title: String
        let attributes: [String: Any] = [NSFontAttributeName: UIFont(name: "Helvetica", size: 10) as Any,
                                         NSForegroundColorAttributeName: UIColor.init(white: 0.2, alpha: 1.0)as Any]
        if started {
            title = NSLocalizedString("Refreshing ...", comment: "")
        } else {
            title = NSLocalizedString("Pull to refresh this directory", comment: "")
        }
        refreshControl?.attributedTitle = NSAttributedString(string: title, attributes: attributes)
    }

    fileprivate func updateContent() {

        self.needRefresh = false
        self.isUpdating = true

        DigiClient.shared.getContent(of: location) { receivedContent, error in
            self.isUpdating = false

            guard error == nil else {

                switch error! {
                case NetworkingError.wrongStatus(let message):
                    self.emptyFolderLabel.text = message
                    self.content.removeAll()
                    self.tableView.reloadData()
                default:

                    if !self.tableView.isDragging {
                        let message = NSLocalizedString("There was an error refreshing the location.", comment: "")
                        let title = NSLocalizedString("Error", comment: "")
                        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    }
                        self.busyIndicator.stopAnimating()
                        self.emptyFolderLabel.text = NSLocalizedString("The location is not available.", comment: "")

                    print("Error: \(error!.localizedDescription)")
                }
                return
            }
            if var newContent = receivedContent {
                switch self.editaction {
                case .copy, .move:
                    // Only in move action, the moved node is not shown in the list.
                    guard let sourceNodes = (self.presentingViewController as? MainNavigationController)?.sourceNodes else {
                        print("Couldn't get the source node.")
                        return
                    }
                    if self.editaction == .move {
                        newContent = newContent.filter {
                            return (!sourceNodes.contains($0) || $0.type == "file")
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
            emptyFolderLabel.text = NSLocalizedString("Directory is Empty", comment: "")
        }
    }

    private func endRefreshAndReloadTable() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.refreshControl?.endRefreshing()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.updateMessageForEmptyFolder()
                self.tableView.reloadData()
                self.setRefreshControlTitle(started: false)
            }
        }
    }

    private func sortContent() {
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

    private func updateNavigationBarRightButtonItems() {

        var rightBarButtonItems = [UIBarButtonItem]()

        if tableView.isEditing {
            rightBarButtonItems.append(cancelInEditModeButton)
        } else {
            var buttonTitle: String
            let isAscending = AppSettings.sortAscending

            switch AppSettings.sortMethod {
            case .byName:        buttonTitle = NSLocalizedString("Name", comment: "") + (isAscending ? " ↑" : " ↓")
            case .byDate:        buttonTitle = NSLocalizedString("Date", comment: "") + (isAscending ? " ↑" : " ↓")
            case .bySize:        buttonTitle = NSLocalizedString("Size", comment: "") + (isAscending ? " ↑" : " ↓")
            case .byContentType: buttonTitle = NSLocalizedString("Type", comment: "") + (isAscending ? " ↑" : " ↓")
            }
            sortBarButton      = UIBarButtonItem(title: buttonTitle, style: .plain, target: self, action: #selector(handleSortSelect))

            rightBarButtonItems.append(contentsOf: [moreActionsBarButton, sortBarButton, searchBarButton])
        }

        navigationItem.setRightBarButtonItems(rightBarButtonItems, animated: false)
    }

    private func updateToolBarButtonItemsToMatchTableState() {
        if tableView.indexPathsForSelectedRows != nil, toolbarItems != nil {
            self.toolbarItems!.forEach { $0.isEnabled = true }
        } else {
            self.toolbarItems!.forEach { $0.isEnabled = false }
        }
    }

    private func sortByName() {
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

    private func sortByDate() {
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

    private func sortBySize() {
        if AppSettings.sortAscending {
            self.content.sort { return $0.type == $1.type ? ($0.size < $1.size) : ($0.type < $1.type) }
        } else {
            self.content.sort { return $0.type == $1.type ? ($0.size > $1.size) : ($0.type < $1.type) }
        }
    }

    private func sortByContentType() {
        if AppSettings.sortAscending {
            self.content.sort { return $0.type == $1.type ? ($0.ext < $1.ext) : ($0.type < $1.type) }
        } else {
            self.content.sort { return $0.type == $1.type ? ($0.ext > $1.ext) : ($0.type < $1.type) }
        }
    }

    fileprivate func resetSearchViewControllerIndex() {
        if let nav = navigationController as? MainNavigationController {
            nav.searchResultsControllerIndex = nil
        }
    }

    private func setBusyIndicatorView(_ visible: Bool) {
        guard let navControllerView = navigationController?.view else {
            return
        }
        if visible {
            let screenSize = navControllerView.bounds.size
            let origin = CGPoint(x: (screenSize.width / 2) - 45, y: (screenSize.height / 2) - 45)
            let frame = CGRect(origin: origin, size: CGSize(width: 90, height: 90))
            let overlayView = UIView(frame: frame)
            overlayView.layer.cornerRadius = 8
            overlayView.backgroundColor = UIColor.init(white: 0.75, alpha: 1.0)
            overlayView.tag = 9999

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
            if let overlayView = navControllerView.viewWithTag(9999) {
                UIView.animate(withDuration: 0.4, animations: {
                    overlayView.alpha = 0
                }, completion: { _ in
                    overlayView.removeFromSuperview()
                })
            }
        }
    }

    @objc private func handleSortSelect() {
        let controller = SortFolderViewController()
        controller.onFinish = { [unowned self](dismiss) in
            if dismiss {
                self.dismiss(animated: true, completion: nil)
            }
            self.sortContent()
            self.tableView.reloadData()
            self.updateNavigationBarRightButtonItems()
        }
        controller.modalPresentationStyle = .popover
        guard let buttonView = navigationItem.rightBarButtonItems?[1].value(forKey: "view") as? UIView else { return }
        controller.popoverPresentationController?.sourceView = buttonView
        controller.popoverPresentationController?.sourceRect = buttonView.bounds
        present(controller, animated: true, completion: nil)
    }

    @objc private func handleShowMoreActions() {
        let controller = MoreActionsViewController(style: .plain)

        controller.modalPresentationStyle = .popover
        guard let buttonView = navigationItem.rightBarButtonItems?[0].value(forKey: "view") as? UIView else { return }
        controller.popoverPresentationController?.sourceView = buttonView
        controller.popoverPresentationController?.sourceRect = buttonView.bounds

        controller.onFinish = { [unowned self] selection in
            self.dismiss(animated: true, completion: nil)

            switch selection {
            case .createDirectory:
                self.handleCreateDirectory()
                break
            case .selectionMode:
                self.activateEditMode()
                break
            }
        }

        present(controller, animated: true, completion: nil)
    }

    @objc private func handleCreateDirectory() {

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

                let controller = ListingViewController(editaction: self.editaction, for: folderLocation)
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

    @objc private func handleDone() {
        self.onFinish?()
    }

    @objc private func handleRefresh() {
        if self.isUpdating {
            self.refreshControl?.endRefreshing()
            return
        }
        setRefreshControlTitle(started: true)
        self.updateContent()
    }

    @objc private func handleSearch() {
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

    private func setNeedsRefreshInMain() {
        // Set needRefresh true in the main Listing controller
        if let nav = self.presentingViewController as? UINavigationController {
            for controller in nav.viewControllers {
                if let controller = controller as? ListingViewController {
                    controller.needRefresh = true
                }
            }
        }
    }

    private func doCopyOrMove(node sourceNode: Node) {
        var destinationLocation = Location(mount: self.location.mount, path: self.location.path + sourceNode.name)

        let index = sourceNode.name.getIndexBeforeExtension()

        if self.editaction == .copy {
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

        dispatchGroup.enter()

        DigiClient.shared.copyOrMoveNode(action: self.editaction, from: sourceNode.location, to: destinationLocation) { statusCode, error in

            #if DEBUG_CONTROLLERS
            print("Task \(taskFinished) finished")
            taskFinished += 1
            #endif

            self.dispatchGroup.leave()

            guard error == nil else {
                self.didReceivedNetworkError = true
                DLog(object: error!.localizedDescription)
                return
            }

            if let code = statusCode {
                switch code {
                case 200:
                    // Operation successfully completed
                    self.setNeedsRefreshInMain()
                    self.didSucceedCopyOrMove = true
                case 400:
                    // Bad request ( Folder already exists, invalid file name?)
                    self.didReceivedStatus400 = true
                case 404:
                    // Not Found (Folder do not exists anymore), folder will refresh
                    self.setNeedsRefreshInMain()
                    self.didReceivedStatus404 = true
                default :
                    print("Server replied with Status Code: ", code)
                }
            }
        }
    }

    @objc private func handleCopyOrMove() {

        setBusyIndicatorView(true)

        guard let sourceNodes = (self.presentingViewController as? MainNavigationController)?.sourceNodes else {
            print("Couldn't get the source node name.")
            return
        }

        didSucceedCopyOrMove = false
        didReceivedNetworkError = false
        didReceivedStatus400 = false
        didReceivedStatus404 = false

        #if DEBUG_CONTROLLERS
        taskStarted = 0
        taskFinished = 0
        #endif

        for sourceNode in sourceNodes {
            doCopyOrMove(node: sourceNode)
        }

        dispatchGroup.notify(queue: DispatchQueue.main) {

            self.setBusyIndicatorView(false)

            if self.didReceivedNetworkError {
                let title = NSLocalizedString("Error", comment: "")
                let message = NSLocalizedString("An error has occured while processing the request.", comment: "")
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                return
            } else {
                if self.didReceivedStatus400 {
                    let message = NSLocalizedString("An error has occured. Some elements already exists at the destination or the destination location no longer exists.", comment: "")
                    let title = NSLocalizedString("Error", comment: "")
                    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                    return
                } else {
                    if self.didReceivedStatus404 {
                        let message = NSLocalizedString("An error has occured. Some elements no longer exists.", comment: "")
                        let title = NSLocalizedString("Error", comment: "")
                        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                            self.onFinish?()
                        }))
                        self.present(alertController, animated: true, completion: nil)
                        return
                    }
                }
            }

            // Finish multiple edits without issues
            self.onFinish?()
        }
    }

    private func activateEditMode() {
        tableView.setEditing(true, animated: true)
        navigationController?.setToolbarHidden(false, animated: true)
        updateNavigationBarRightButtonItems()
        updateToolBarButtonItemsToMatchTableState()
    }

    @objc private func cancelEditMode() {
        tableView.setEditing(false, animated: true)
        navigationController?.setToolbarHidden(true, animated: true)
        updateNavigationBarRightButtonItems()
    }

    @objc private func handleMultipleItemsEdit(_ sender: UIBarButtonItem) {

        guard let chosenAction = ActionType(rawValue: sender.tag) else { return }
        guard let selectedItemsIndexPaths = tableView.indexPathsForSelectedRows else { return }

        let nodes = selectedItemsIndexPaths.map { content[$0.row] }

        switch chosenAction {
        case .delete:
            self.doDelete(nodes: nodes)
        case .copy, .move:
            self.showViewControllerForCopyOrMove(action: chosenAction, nodes: nodes)
        default:
            break
        }
    }

    private func doDelete(nodes: [Node]) {
        guard isActionConfirmed else {

            let string: String
            if nodes.count == 1 {
                if nodes.first!.type == "dir" {
                    string = NSLocalizedString("Are you sure you want to delete this directory?", comment: "")
                } else {
                    string = NSLocalizedString("Are you sure you want to delete this file?", comment: "")
                }
            } else {
                string = NSLocalizedString("Are you sure you want to delete %d items?", comment: "")
            }

            let title = String.localizedStringWithFormat(string, nodes.count)
            let message = NSLocalizedString("This action is not reversible.", comment: "")
            let confirmationController = UIAlertController(title: title, message: message, preferredStyle: .alert)

            let deleteAction = UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .destructive, handler: { _ in
                self.isActionConfirmed = true
                self.doDelete(nodes: nodes)
            })

            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
            confirmationController.addAction(deleteAction)
            confirmationController.addAction(cancelAction)
            present(confirmationController, animated: true, completion: nil)
            return
        }

        self.isActionConfirmed = false
        self.setBusyIndicatorView(true)

        didSucceedCopyOrMove = false
        didReceivedNetworkError = false
        didReceivedStatus400 = false
        didReceivedStatus404 = false

        nodes.forEach {

            self.dispatchGroup.enter()

            DigiClient.shared.deleteNode(at: $0.location) { _, error in
                // TODO: Stop spinner
                guard error == nil else {
                    // TODO: Show message for error
                    print(error!.localizedDescription)
                    return
                }
                // TODO: Handle http status code
                self.dispatchGroup.leave()
            }
        }

        // After all deletions have finished...
        dispatchGroup.notify(queue: DispatchQueue.main) {
            self.setBusyIndicatorView(false)
            self.cancelEditMode()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.updateContent()
            }
        }

    }

    fileprivate func showViewControllerForCopyOrMove(action: ActionType, nodes: [Node]) {

        func updateTableState() {

            // Clear source nodes
            (self.navigationController as? MainNavigationController)?.sourceNodes = nil

            if self.needRefresh {

                if self.tableView.isEditing {
                    self.cancelEditMode()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        self.updateContent()
                    }
                } else {
                    self.updateContent()
                }
            }
        }

        // Save the source node in the MainNavigationController
        (self.navigationController as? MainNavigationController)?.sourceNodes = nodes

        guard let stackControllers = self.navigationController?.viewControllers else {
            print("Couldn't get the previous navigation controllers!")
            return
        }

        var controllers: [UIViewController] = []

        for controller in stackControllers {

            if controller is LocationsViewController {

                let c = LocationsViewController(action: action)
                c.title = NSLocalizedString("Locations", comment: "")

                c.onFinish = { [unowned self] in
                    self.dismiss(animated: true) {
                        updateTableState()
                    }
                }

                controllers.append(c)
                continue

            } else {

                let c = ListingViewController(editaction: action, for: (controller as! ListingViewController).location)
                c.title = controller.title

                c.onFinish = { [unowned self] in
                    self.dismiss(animated: true) {
                       updateTableState()
                    }
                }

                controllers.append(c)
            }

        }

        let navController = UINavigationController(navigationBarClass: CustomNavBar.self, toolbarClass: nil)
        navController.setViewControllers(controllers, animated: false)
        navController.modalPresentationStyle = .formSheet
        self.present(navController, animated: true, completion: nil)

    }
}

extension ListingViewController: UIPopoverPresentationControllerDelegate {
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        self.animateActionButton(active: false)
        return true
    }
}

extension ListingViewController: NodeActionsViewControllerDelegate {
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

                self.showViewControllerForCopyOrMove(action: action, nodes: [node])

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

        let controller = NodeActionsViewController(node: self.content[indexPath.row])
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
                    let message = NSLocalizedString("There was an error while deleting.", comment: "")
                    let title = NSLocalizedString("Error", comment: "")
                    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
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
        self.resetSearchViewControllerIndex()
        src.filteredContent.removeAll()
        src.tableView.reloadData()
    }
}
