//
//  NodeActionsViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 20/10/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

final class NodeActionsViewController: UITableViewController {

    // MARK: - Properties

    var onSelect: ((ActionType) -> Void)?

    private var location: Location
    private let node: Node

    private var actions: [ActionType] = []

    // MARK: - Initializers and Deinitializers

    init(location: Location, node: Node) {
        self.location = location
        self.node = node
        super.init(style: .plain)
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
        registerForNotificationCenter()
        setupViews()
        setupPermittedActions()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.preferredContentSize.width = 350
        self.preferredContentSize.height = tableView.contentSize.height - 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.textColor = UIColor.defaultColor

        switch actions[indexPath.row] {

        case .makeShare:
            cell.textLabel?.text = NSLocalizedString("Share", comment: "")

        case .manageShare:
            cell.textLabel?.text = NSLocalizedString("Manage Share", comment: "")

        case .shareInfo:
            cell.textLabel?.text = NSLocalizedString("See Share Members", comment: "")

        case .sendDownloadLink:
            cell.textLabel?.text = NSLocalizedString("Send Link", comment: "")

        case .sendUploadLink:
            cell.textLabel?.text = NSLocalizedString("Receive Files", comment: "")

        case .makeOffline:
            cell.textLabel?.text = NSLocalizedString("Make available offline", comment: "")

        case .bookmark:
            cell.textLabel?.text = self.node.bookmark == nil
                ? NSLocalizedString("Add Bookmark", comment: "")
                : NSLocalizedString("Remove Bookmark", comment: "")

        case .rename:
            cell.textLabel?.text = NSLocalizedString("Rename", comment: "")

        case .copy:
            cell.textLabel?.text = NSLocalizedString("Copy", comment: "")

        case .move:
            cell.textLabel?.text = NSLocalizedString("Move", comment: "")

        case .delete:
            cell.textLabel?.text = NSLocalizedString("Delete", comment: "")
            cell.textLabel?.textColor = .red

        case .folderInfo:
            cell.textLabel?.text = NSLocalizedString("Folder information", comment: "")

        default:
            break
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: false) {
            self.onSelect?(self.actions[indexPath.row])
        }
    }

    // MARK: - Helper Functions

    private func registerForNotificationCenter() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCancel),
            name: .UIApplicationWillResignActive,
            object: nil)
    }

    private func setupViews() {

        if navigationController != nil {
            title = node.name

            let closeButton: UIBarButtonItem = {
                let button = UIBarButtonItem(title: NSLocalizedString("Close", comment: ""), style: .done, target: self, action: #selector(handleCancel))
                return button
            }()

            self.navigationItem.rightBarButtonItem = closeButton

        } else {

            let headerView: UIView = {
                let view = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: AppSettings.tableViewRowHeight))
                view.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
                return view
            }()

            let iconImage: UIImageView = {
                let image = node.type == "dir" ? #imageLiteral(resourceName: "folder_icon") : #imageLiteral(resourceName: "file_icon")
                let imageView = UIImageView(image: image)
                imageView.contentMode = .scaleAspectFit
                imageView.translatesAutoresizingMaskIntoConstraints = false
                return imageView
            }()

            let elementName: UILabel = {
                let label = UILabel()
                label.translatesAutoresizingMaskIntoConstraints = false
                label.text = node.name
                label.font = UIFont.boldSystemFont(ofSize: 16)
                return label
            }()

            let separator: UIView = {
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                view.backgroundColor = UIColor(white: 0.8, alpha: 1)
                return view
            }()

            headerView.addSubview(iconImage)
            headerView.addSubview(elementName)
            headerView.addSubview(separator)

            let offset: CGFloat = node.type == "dir" ? 20 : 18

            NSLayoutConstraint.activate([

                iconImage.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: offset),
                iconImage.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
                iconImage.widthAnchor.constraint(equalToConstant: 26),
                iconImage.heightAnchor.constraint(equalToConstant: 26),

                elementName.leftAnchor.constraint(equalTo: iconImage.rightAnchor, constant: 10),
                elementName.rightAnchor.constraint(equalTo: headerView.rightAnchor, constant: -10),
                elementName.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

                separator.leftAnchor.constraint(equalTo: headerView.leftAnchor),
                separator.rightAnchor.constraint(equalTo: headerView.rightAnchor),
                separator.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale)
            ])

            tableView.tableHeaderView = headerView
        }

        tableView.isScrollEnabled = false
        tableView.rowHeight = AppSettings.tableViewRowHeight
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
    }

    private func setupPermittedActions() {

        // order of elements in important for UI.

        if node.type == "dir" {

            if location.mount.permissions.createLink {
                actions.append(.sendDownloadLink)
            }

            if location.mount.permissions.createReceiver {
                actions.append(.sendUploadLink)
            }

            if node.mount != nil {
                if node.mount?.type == "export" {
                    actions.append(.manageShare)
                }
            } else {
                if location.mount.permissions.owner == true {
                    actions.append(.makeShare)
                }
            }

            actions.append(.bookmark)

            if location.mount.canWrite {
                actions.append(.rename)
            }

            actions.append(.copy)

            // Keep order in menu
            if location.mount.canWrite {
                actions.append(.move)
            }

            actions.append(.folderInfo)

        } else {

            if location.mount.permissions.createLink {
                actions.append(.sendDownloadLink)
            }

            if location.mount.canWrite {
                actions.append(.rename)
            }

            actions.append(.copy)

            // Keep order in menu
            if location.mount.canWrite {
                actions.append(.move)
            }

            if location.mount.canWrite {
                actions.append(.delete)
            }
        }
    }

    @objc private func handleCancel() {
        dismiss(animated: true, completion: nil)
    }

}
