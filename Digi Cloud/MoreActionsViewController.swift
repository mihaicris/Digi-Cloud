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
        setupViews()
        setupActions()
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        preferredContentSize.width = 250
        preferredContentSize.height = tableView.contentSize.height - 1
        super.viewWillAppear(animated)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.textColor = UIColor.defaultColor

        switch actions[indexPath.row] {

        case .makeNewShare:
            cell.textLabel?.text = NSLocalizedString("Share", comment: "")

        case .manageShare:
            cell.textLabel?.text = NSLocalizedString("Manage Share", comment: "")

        case .shareInfo:
            cell.textLabel?.text = NSLocalizedString("See Share Members", comment: "")

        case .bookmark:
            cell.textLabel?.text = self.rootNode.bookmark == nil
                ? NSLocalizedString("Set Bookmark", comment: "")
                : NSLocalizedString("Remove Bookmark", comment: "")

        case .createDirectory:
            cell.textLabel?.text = NSLocalizedString("Create Directory", comment: "")

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
        let headerView: UIView = {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
            view.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
            return view
        }()

        let message: UILabel = {
            let label = UILabel()
            label.textAlignment = .center
            label.text = NSLocalizedString("More actions", comment: "")
            label.font = UIFont.systemFont(ofSize: 14)
            return label
        }()

        let separator: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor(white: 0.8, alpha: 1)
            return view
        }()

        headerView.addSubview(message)
        headerView.addConstraints(with: "H:|-10-[v0]-10-|", views: message)
        message.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true

        headerView.addSubview(separator)
        headerView.addConstraints(with: "H:|[v0]|", views: separator)
        headerView.addConstraints(with: "V:[v0(\(1 / UIScreen.main.scale))]|", views: separator)

        tableView.isScrollEnabled = false
        tableView.rowHeight = 50
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
    }

    private func setupActions() {

        guard let mount = rootNode.mount else {
            print("NO MOUNT??")
            fatalError()
        }

        if mount.type == "device" {
            if mount.root == nil && rootNode.mountPath == "/" {
                actions.append(.manageShare)
            } else {
                actions.append(.makeNewShare)
            }
        } else if mount.type == "export" {
            actions.append(.manageShare)
        } else if rootNode.mountPath == "/" {
            if mount.permissions.mount {
                actions.append(.manageShare)
            } else {
                actions.append(.shareInfo)
            }
        }

        actions.append(.bookmark)

        if mount.canWrite {
            actions.append(.createDirectory)
        }

        if childs > 1 {
            actions.append(.selectionMode)
        }
    }
}
