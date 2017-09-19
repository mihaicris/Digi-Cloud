//
//  MoreActionsViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 02/02/2017.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import UIKit

final class MoreActionsViewController: UITableViewController {

    // MARK: - Properties

    var onSelect: ((ActionType) -> Void)?

    private let rootNode: Node

    private var actions: [ActionType] = []

    private let childs: Int

    // MARK: - Initializers and Deinitializers

    init(rootNode: Node, childs: Int) {
        self.rootNode = rootNode
        self.childs = childs
        super.init(style: .plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit { DEINITLog(self) }

    // MARK: - Overridden Methods and Properties

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupActions()
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

        case .sendDownloadLink:
            cell.textLabel?.text = NSLocalizedString("Send Link", comment: "")

        case .sendUploadLink:
            cell.textLabel?.text = NSLocalizedString("Receive Files", comment: "")

        case .makeShare:
            cell.textLabel?.text = NSLocalizedString("Share", comment: "")

        case .manageShare:
            cell.textLabel?.text = NSLocalizedString("Manage Share", comment: "")

        case .shareInfo:
            cell.textLabel?.text = NSLocalizedString("See Share Members", comment: "")

        case .bookmark:
            cell.textLabel?.text = self.rootNode.bookmark == nil
                ? NSLocalizedString("Set Bookmark", comment: "")
                : NSLocalizedString("Remove Bookmark", comment: "")

        case .createFolder:
            cell.textLabel?.text = NSLocalizedString("Create Folder", comment: "")

        case .selectionMode:
            cell.textLabel?.text = NSLocalizedString("Select Mode", comment: "")

        default:
            break
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        self.dismiss(animated: true) {
            self.onSelect?(self.actions[indexPath.row])
        }
    }

    // MARK: - Helper Functions

    private func setupViews() {

        if navigationController != nil {
            title = NSLocalizedString("More actions", comment: "")

            let closeButton: UIBarButtonItem = {
                let b = UIBarButtonItem(title: NSLocalizedString("Close", comment: ""), style: .done, target: self, action: #selector(handleCancel))
                return b
            }()

            self.navigationItem.rightBarButtonItem = closeButton

        } else {

            let headerView: UIView = {
                let view = UIView(frame: CGRect(x: 0, y: 0, width:400, height: 40))
                view.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
                return view
            }()

            let titleName: UILabel = {
                let l = UILabel()
                l.translatesAutoresizingMaskIntoConstraints = false
                l.textAlignment = .center
                l.text = NSLocalizedString("More actions", comment: "")
                l.font = UIFont.boldSystemFont(ofSize: 16)
                return l
            }()

            let separator: UIView = {
                let v = UIView()
                v.backgroundColor = UIColor(white: 0.8, alpha: 1)
                return v
            }()

            headerView.addSubview(titleName)
            titleName.centerXAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true
            titleName.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true

            headerView.addSubview(separator)
            headerView.addConstraints(with: "H:|[v0]|", views: separator)
            headerView.addConstraints(with: "V:[v0(\(1 / UIScreen.main.scale))]|", views: separator)
            tableView.rowHeight = AppSettings.tableViewRowHeight
            tableView.tableHeaderView = headerView

        }

        tableView.isScrollEnabled = false
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
    }

    private func setupActions() {

        guard let mount = rootNode.mount else {
            dismiss(animated: false, completion: nil)
            return
        }

        if mount.permissions.create_link {
            actions.append(.sendDownloadLink)
        }

        if mount.permissions.create_receiver {
            actions.append(.sendUploadLink)
        }

        if mount.type == "device" {
            if mount.root == nil && rootNode.mountPath == "/" {
                if mount.users.count > 1 {
                    actions.append(.manageShare)
                } else {
                    actions.append(.makeShare)
                }
            }
        } else if mount.type == "export" {
            if rootNode.mountPath == "/" {
                actions.append(.manageShare)
            }
        } else if rootNode.mountPath == "/" {
            if mount.permissions.mount {
                actions.append(.manageShare)
            } else {
                actions.append(.shareInfo)
            }
        }

        actions.append(.bookmark)

        if mount.canWrite {
            actions.append(.createFolder)
        }

        if childs > 1 {
            actions.append(.selectionMode)
        }
    }

    @objc private func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
}
