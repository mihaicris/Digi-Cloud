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

    var location: Location
    var needRefresh: Bool = false
    var content: [Node] = []
    var currentIndex: IndexPath!
    private let FileCellID = "FileCellWithButton"
    private let FolderCellID = "DirectoryCellWithButton"
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

    init(location: Location) {
        self.location = location
        super.init(style: .plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        DigiClient.shared.task?.cancel()
        #if DEBUG
            print("[DEINIT]: " + String(describing: type(of: self)))
        #endif
    }

    // MARK: - Overridden Methods and Properties

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        getFolderContent()
    }

    override func viewWillAppear(_ animated: Bool) {
        updateRightBarButtonItems()
        if needRefresh {
            content.removeAll()
            self.busyIndicator.startAnimating()
            self.emptyFolderLabel.text = NSLocalizedString("Loading ...", comment: "Information")
            tableView.reloadData()
        }
        super.viewWillAppear(animated)
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

            let controller = ListingViewController(location: nextLocation)
            controller.title = item.name
            navigationController?.pushViewController(controller, animated: true)

        } else {
            // This is a file

            let nextPath = self.location.path + item.name
            let nextLocation = Location(mount: self.location.mount, path: nextPath)

            let controller = ContentViewController(location: nextLocation)
            controller.title = item.name
            navigationController?.pushViewController(controller, animated: true)
        }
    }

    // MARK: - Helper Methods

    private func setupTableView() {
        tableView.register(FileCell.self, forCellReuseIdentifier: FileCellID)
        tableView.register(DirectoryCell.self, forCellReuseIdentifier: FolderCellID)
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.rowHeight = AppSettings.tableViewRowHeight
    }

    func getFolderContent() {

        self.needRefresh = false

        DigiClient.shared.getLocationContent(location: location) {
            (content, error) in
            guard error == nil else {
                print("Error: \(error!.localizedDescription)")
                return
            }
            if let content = content {
                if !content.isEmpty {
                    self.content = content
                    self.sortContent()
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.busyIndicator.stopAnimating()
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

    func sortContent() {
        switch AppSettings.sortMethod {
        case .byName:        sortByName()
        case .byDate:        sortByDate()
        case .bySize:        sortBySize()
        case .byContentType: sortByContentType()
        }
    }

    func animateActionButton(active: Bool) {
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
        addFolderButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(handleAddFolder))
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

    @objc fileprivate func handleSortSelect() {
        let controller = SortFolderViewController()
        controller.onFinish = { [unowned self](dismiss) in
            if dismiss {
                self.dismiss(animated: true, completion: nil) }
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

    @objc fileprivate func handleAddFolder() {
        self.dismiss(animated: false, completion: nil) // dismiss any other presented controller
        let controller = CreateFolderViewController(location: location)
        controller.location = self.location
        controller.onFinish = { [unowned self](folderName) in
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil) // dismiss AddFolderViewController
                if let folderName = folderName {
                    self.needRefresh = true
                    let nextPath = self.location.path + folderName
                    let newLocation = Location(mount: self.location.mount, path: nextPath)
                    let controller = ListingViewController(location: newLocation)
                    controller.title = folderName
                    self.navigationController?.pushViewController(controller, animated: true)
                } else {
                    return // Cancel
                }
            }
        }
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.modalPresentationStyle = .formSheet
        present(navigationController, animated: true, completion: nil)
    }
}

extension ListingViewController: UIPopoverPresentationControllerDelegate {
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        self.animateActionButton(active: false)
        return true
    }
}
