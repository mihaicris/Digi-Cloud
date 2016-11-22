//
//  MoveTableViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 15/11/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

final class CopyOrMoveViewController: UITableViewController {

    // MARK: - Properties

    var onFinish: (() -> Void)?

    private let mountID: String
    private let path: String
    private let FileCellID = "FileCell"
    private let FolderCellID = "DirectoryCell"
    private var needRefresh: Bool = true
    private var node: Node?
    private var action: ActionType
    private var content: [Node] = []
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

    // MARK: - Initializers and Deinitializers

    init(mountID: String, path: String, node: Node?, action: ActionType) {
        self.mountID = mountID
        self.path = path
        self.node = node
        self.action = action
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

        self.automaticallyAdjustsScrollViewInsets = true
        tableView.register(FileCell.self, forCellReuseIdentifier: FileCellID)
        tableView.register(DirectoryCell.self, forCellReuseIdentifier: FolderCellID)
        tableView.rowHeight = AppSettings.tableViewRowHeight

        setupViews()
    }

    override func viewWillAppear(_ animated: Bool) {
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
            tableView.separatorStyle = .none
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

        tableView.separatorStyle = .singleLine
        let data = content[indexPath.row]

        if data.type == "dir" {
            let cell = tableView.dequeueReusableCell(withIdentifier: FolderCellID, for: indexPath) as! DirectoryCell
            cell.folderNameLabel.text = data.name
            return cell

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: FileCellID, for: indexPath) as! FileCell

            let modifiedDate = dateFormatter.string(from: Date(timeIntervalSince1970: data.modified / 1000))
            cell.fileNameLabel.text = data.name

            let fileSizeString = byteFormatter.string(fromByteCount: data.size) + "・" + modifiedDate
            cell.fileSizeLabel.text = fileSizeString

            return cell
        }
    }

    // MARK: - Helper Functions

    private func getFolderContent() {

        self.needRefresh = false

        DigiClient.shared.getLocationContent(mountID: self.mountID, path: self.path) {
            (content, error) in
            guard error == nil else {
                print("Error: \(error!.localizedDescription)")
                return
            }

            if var content = content {
                if !content.isEmpty {

                    // Remove from the list the node which is copied or moved
                    if let node = self.node {
                        for (index, elem) in content.enumerated() {
                            if elem.name == node.name {
                                content.remove(at: index)
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
                DispatchQueue.main.async {
                    self.emptyFolderLabel.text = NSLocalizedString("Folder is Empty", comment: "Information")
                    self.busyIndicator.stopAnimating()
                }
            }
        }
    }

    private func setupViews() {

        view.backgroundColor = UIColor.white
        self.navigationItem.prompt = NSLocalizedString("Choose a destination", comment: "Window prompt")


        var buttonTitle: String

        switch action {
        case .copy:
            buttonTitle = NSLocalizedString("Save copy", comment: "Button Title")
        case .move:
            buttonTitle = NSLocalizedString("Move", comment: "Button Title")
        default:
            return
        }

        let rightButton = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: "Button Title"), style: .plain, target: self, action: #selector(handleDone))

        navigationItem.setRightBarButton(rightButton, animated: false)
        navigationController?.isToolbarHidden = false

        let copyMoveButton = UIBarButtonItem(title: buttonTitle, style: .plain, target: self, action: #selector(handleCopyOrMove))

        // TODO: Activate when source and destination paths are not the same
        copyMoveButton.isEnabled = false

        let toolBarItems = [UIBarButtonItem(title: NSLocalizedString("New Folder", comment: "Button Title"), style: .plain, target: self, action: #selector(handleNewFolder)),
                            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                            copyMoveButton]

        self.setToolbarItems(toolBarItems, animated: false)
    }

    @objc private func handleDone() {
        self.onFinish?()
    }

    @objc private func handleNewFolder() {
        let controller = CreateFolderViewController(mountID: self.mountID, path: self.path)
        controller.path = self.path
        controller.onFinish = { [unowned self](folderName) in
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
                guard let folderName = folderName,
                    let nextPath = String("\(self.path)\(folderName)")
                    else {
                        print("Cannot create next Path")
                        return
                    }
                    // Set needRefresh in this list
                    self.needRefresh = true

                    // Set needRefresh in the main List
                    if let nav = self.presentingViewController as? UINavigationController {
                        if let cont = nav.topViewController as? ListingViewController {
                            cont.needRefresh = true
                        }
                    }

                    let newController = CopyOrMoveViewController(mountID: self.mountID,
                                                                 path: nextPath,
                                                                 node: nil,
                                                                 action: self.action)
                    newController.onFinish = { [unowned self] in
                        self.onFinish?()
                    }
                    self.navigationController?.pushViewController(newController, animated: true)

            }
        }
        let navController = UINavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true, completion: nil)
    }

    @objc private func handleCopyOrMove() {
    }
}

