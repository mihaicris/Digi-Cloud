//
//  ListingViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 19/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

final class ListingViewController: UITableViewController {

    // MARK: - Properties
    var onFinish: (() -> Void)?
    let action: ActionType
    var location: Location
    var node: Node?
    var needRefresh: Bool = true
    var content: [Node] = []
    var currentIndex: IndexPath!
    private var FileCellID: String = ""
    private var FolderCellID: String = ""
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
        i.startAnimating()
        i.activityIndicatorViewStyle = .gray
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()
    private let emptyFolderLabel: UILabel = {
        let l = UILabel()
        l.text = NSLocalizedString("Loading ...", comment: "Information")
        l.textColor = UIColor.lightGray
        l.sizeToFit()
        l.textAlignment = .center
        return l
    }()
    private var addFolderButton, sortButton: UIBarButtonItem!

    // MARK: - Initializers and Deinitializers

    init(action: ActionType, for location: Location, remove node: Node?) {
        self.action = action
        self.location = location
        self.node = node
        super.init(style: .plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    #if DEBUG
    deinit {
        print("[DEINIT]: " + String(describing: type(of: self)))
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
        }

        if needRefresh {
            content.removeAll()
            self.busyIndicator.startAnimating()
            self.emptyFolderLabel.text = NSLocalizedString("Loading ...", comment: "Information")
            tableView.reloadData()
        }
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        DigiClient.shared.task?.cancel()
        super.viewWillDisappear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if needRefresh {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                self.getFolderContent()
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return content.isEmpty ? 2 : content.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if content.isEmpty {
            let cell = UITableViewCell()
            cell.isUserInteractionEnabled = false
            tableView.separatorColor = .white
            if indexPath.row == 1 {

                let v = UIView()
                v.translatesAutoresizingMaskIntoConstraints = false
                v.addSubview(busyIndicator)
                v.addSubview(emptyFolderLabel)
                v.addConstraints(with: "H:|[v0]-5-[v1]|", views: busyIndicator, emptyFolderLabel)
                busyIndicator.centerYAnchor.constraint(equalTo: v.centerYAnchor).isActive = true
                emptyFolderLabel.centerYAnchor.constraint(equalTo: v.centerYAnchor).isActive = true

                cell.contentView.addSubview(v)
                v.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor).isActive = true
                v.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
            }
            return cell
        }

        tableView.separatorColor = nil

        let data = content[indexPath.row]

        if data.type == "dir" {
            let cell = tableView.dequeueReusableCell(withIdentifier: FolderCellID, for: indexPath) as! DirectoryCell
            cell.delegate = self

            cell.folderNameLabel.text = data.name

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: FileCellID, for: indexPath) as! FileCell
            cell.delegate = self

            let modifiedDate = dateFormatter.string(from: Date(timeIntervalSince1970: data.modified / 1000))
            cell.fileNameLabel.text = data.name

            let fileSizeString = byteFormatter.string(fromByteCount: data.size) + "・" + modifiedDate
            cell.fileSizeLabel.text = fileSizeString

            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: false)

        let item = content[indexPath.row]

        if item.type == "dir" {
            // This is a Folder

            let nextPath = self.location.path + item.name + "/"
            let nextLocation = Location(mount: self.location.mount, path: nextPath)

            let controller = ListingViewController(action: self.action, for: nextLocation, remove: nil)
            controller.title = item.name
            controller.onFinish = { [unowned self] in
                self.onFinish?()
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

    // MARK: - Helper Methods

    private func setupTableView() {

        switch self.action {
        case .copy, .move:
            self.FileCellID = "FileCell"
            self.FolderCellID = "DirectoryCell"
        default:
            self.FileCellID = "FileCellWithButton"
            self.FolderCellID = "DirectoryCellWithButton"
        }

        tableView.register(FileCell.self, forCellReuseIdentifier: FileCellID)
        tableView.register(DirectoryCell.self, forCellReuseIdentifier: FolderCellID)
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.rowHeight = AppSettings.tableViewRowHeight
    }

    private func setupViews() {
        self.automaticallyAdjustsScrollViewInsets = true
        switch self.action {
        case .copy, .move:
            self.navigationItem.prompt = NSLocalizedString("Choose a destination", comment: "Window prompt")

            let rightButton = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: "Button Title"), style: .plain, target: self, action: #selector(handleDone))
            navigationItem.setRightBarButton(rightButton, animated: false)
            navigationController?.isToolbarHidden = false

            let buttonTitle = self.action == .copy ? NSLocalizedString("Save copy", comment: "Button Title") : NSLocalizedString("Move", comment: "Button Title")
            let copyMoveButton = UIBarButtonItem(title: buttonTitle, style: .plain, target: self, action: #selector(handleCopyOrMove))
            // TODO: Activate when source and destination paths are not the same
            copyMoveButton.isEnabled = true
            let toolBarItems = [UIBarButtonItem(title: NSLocalizedString("Create Folder", comment: "Button Title"), style: .plain, target: self, action: #selector(handleCreateFolder)),
                                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                                copyMoveButton]
            setToolbarItems(toolBarItems, animated: false)
        default:
            break
        }
    }

    fileprivate func getFolderContent() {

        self.needRefresh = false

        DigiClient.shared.getLocationContent(location: location) {
            (content, error) in
            guard error == nil else {
                print("Error: \(error!.localizedDescription)")
                return
            }
            if var content = content {
                if !content.isEmpty {
                    if self.action == .noAction {
                        // No copy or move, no node to be removed, usual sort and display
                        self.content = content
                        self.sortContent()
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            self.busyIndicator.stopAnimating()
                        }
                    } else {

                        // Copy or remove action! The indicated node will be removed, sort by name and display
                        // Remove from the list the node which is copied or moved
                        if let node = self.node {
                            for (index, elem) in content.enumerated() {
                                if elem.name == node.name {
                                    content.remove(at: index)
                                    break
                                }
                            }
                        }
                        if !content.isEmpty {
                            // Sort the content by name ascending with folders shown first
                            content.sort { return $0.type == $1.type ? ($0.name.lowercased() < $1.name.lowercased()) : ($0.type < $1.type) }

                            self.content = content

                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.emptyFolderLabel.text = NSLocalizedString("Folder is Empty", comment: "Information")
                        self.busyIndicator.stopAnimating()
                    }
                }
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
        let actionButton = (tableView.cellForRow(at: currentIndex) as! BaseListCell).actionButton
        let transform = active ? CGAffineTransform.init(rotationAngle: CGFloat(M_PI_2)) : CGAffineTransform.identity
        let color: UIColor = active ? .black : .darkGray
        actionButton.setTitleColor(color, for: .normal)
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIViewAnimationOptions.curveEaseOut, animations: {
            actionButton.transform = transform
        }, completion: nil)
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
        sortButton      = UIBarButtonItem(title: buttonTitle, style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleSortSelect))
        addFolderButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(handleCreateFolder))
        navigationItem.setRightBarButtonItems([sortButton, addFolderButton], animated: false)
    }

    fileprivate func sortByName() {
        if AppSettings.showFoldersFirst {
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
        if AppSettings.showFoldersFirst {
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

    @objc private func handleSortSelect() {
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

    @objc private func handleCreateFolder() {
        let controller = CreateFolderViewController(location: location)
        controller.location = self.location
        controller.onFinish = { [unowned self](folderName) in
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil) // dismiss AddFolderViewController

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

                let controller = ListingViewController(action: self.action, for: folderLocation, remove: nil)
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

    @objc private func handleCopyOrMove() {
        // TODO: Calculate the path
        print("User selected a path")
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
        dismiss(animated: true, completion: nil) // dismiss ActionsViewController

        let node: Node = content[currentIndex.row]

        switch action {
        case .rename:
            let controller = RenameViewController(location: location, node: node)
            controller.onFinish = { (newName, needRefresh) in

                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil) // dismiss RenameViewController
                }
                if let name = newName {

                    self.content[self.currentIndex.row] = Node(name:        name,
                                                               type:        node.type,
                                                               modified:    node.modified,
                                                               size:        node.size,
                                                               contentType: node.contentType)
                    self.sortContent()
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } else {
                    if needRefresh {
                        self.getFolderContent()
                    }
                }
            }
            let navController = UINavigationController(rootViewController: controller)
            navController.modalPresentationStyle = .formSheet
            present(navController, animated: true, completion: nil)

        case .copy, .move:

            guard let previousControllers = navigationController?.viewControllers else {
                print("Couldn't get the previous navigation controllers!")
                return
            }

            var controllers: [UIViewController] = []

            for (index, p) in previousControllers.enumerated() {

                // If index is 0 than this is a location controller
                if index == 0 {
                    let c = LocationsTableViewController(action: action)
                    c.title = NSLocalizedString("Locations", comment: "Window Title")
                    c.onFinish = { [unowned self] in
                        self.dismiss(animated: true, completion: nil)
                        if self.needRefresh {
                            self.getFolderContent()
                        }
                    }
                    controllers.append(c)
                    continue
                }

                // we need to cast in order to tet the mountID and path from it
                if let p = p as? ListingViewController {

                    // If index is the last one, we need to inject the current node which is
                    // moved or copied, such that it won't be shown in the list.
                    let specificNode = index == previousControllers.count - 1 ? node : nil

                    let c = ListingViewController(action: action, for: p.location, remove: specificNode)
                    c.title = p.title
                    c.onFinish = { [unowned self] in
                        self.dismiss(animated: true, completion: nil)
                        if self.needRefresh {
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                                self.getFolderContent()
                            }
                        }
                    }
                    controllers.append(c)
                }
            }

            let navController = UINavigationController(navigationBarClass: CustomNavBar.self, toolbarClass: nil)
            navController.setViewControllers(controllers, animated: false)
            navController.modalPresentationStyle = .formSheet
            present(navController, animated: true, completion: nil)

        case .delete:

            if node.type == "file" {
                let controller = DeleteViewController(node: node)
                controller.delegate = self

                // position alert on the same row with the file
                var sourceView = tableView.cellForRow(at: currentIndex)!.contentView
                for view in sourceView.subviews {
                    if view.tag == 1 {
                        sourceView = view.subviews[0]
                    }
                }
                controller.modalPresentationStyle = .popover
                controller.popoverPresentationController?.sourceView = sourceView
                controller.popoverPresentationController?.sourceRect = sourceView.bounds
                present(controller, animated: true, completion: nil)
            }

        case .folderInfo:
            let controller = FolderInfoViewController(location: self.location, node: node)
            controller.onFinish = { (success, needRefresh) in
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil) // dismiss FolderViewController
                    if success {
                        self.content.remove(at: self.currentIndex.row)
                        self.tableView.deleteRows(at: [self.currentIndex], with: .left)
                    } else {
                        if needRefresh {
                            self.getFolderContent()
                        }
                    }
                }
            }
            let navController = UINavigationController(rootViewController: controller)
            navController.modalPresentationStyle = .formSheet
            present(navController, animated: true, completion: nil)
            
        default:
            return
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
            DigiClient.shared.deleteNode(location: deleteLocation) {

                (statusCode, error) in

                // TODO: Stop spinner
                guard error == nil else {
                    // TODO: Show message for error
                    print(error!.localizedDescription)
                    return
                }
                if let code = statusCode {
                    DispatchQueue.main.async {
                        switch code {
                        case 200:
                            self.content.remove(at: self.currentIndex.row)
                            self.tableView.deleteRows(at: [self.currentIndex], with: .left)
                        case 400:
                            self.getFolderContent()
                        case 404:
                            self.getFolderContent()
                        default :
                            break
                        }
                    }
                } else {
                    print("Error: could not obtain a statuscode")
                }
            }
        }
    }
}
