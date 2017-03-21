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
        INITLog(self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit { DEINITLog(self) }

    // MARK: - Overridden Methods and Properties

    override func viewDidLoad() {
        setupViews()
        setupPermittedActions()
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.preferredContentSize.width = 250
        self.preferredContentSize.height = tableView.contentSize.height - 1
        super.viewWillAppear(animated)
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
                ? NSLocalizedString("Set Bookmark", comment: "")
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

        case .directoryInfo:
            cell.textLabel?.text = NSLocalizedString("Directory information", comment: "")

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

    private func setupViews() {

        let headerView: UIView = {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 50))
            view.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
            return view
        }()

        let iconImage: UIImageView = {
            let image = node.type == "dir" ? #imageLiteral(resourceName: "directory_icon") : #imageLiteral(resourceName: "file_icon")
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            return imageView
        }()

        let elementName: UILabel = {
            let label = UILabel()
            label.text = node.name
            label.font = UIFont.systemFont(ofSize: 14)
            return label
        }()

        let separator: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor(white: 0.8, alpha: 1)
            return view
        }()

        headerView.addSubview(iconImage)
        headerView.addSubview(elementName)

        let offset = node.type == "dir" ? 22 : 20
        headerView.addConstraints(with: "H:|-\(offset)-[v0(26)]-10-[v1]-10-|", views: iconImage, elementName)
        headerView.addConstraints(with: "V:[v0(26)]", views: iconImage)
        iconImage.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        elementName.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true

        headerView.addSubview(separator)
        headerView.addConstraints(with: "H:|[v0]|", views: separator)
        headerView.addConstraints(with: "V:[v0(\(1 / UIScreen.main.scale))]|", views: separator)

        tableView.isScrollEnabled = false
        tableView.rowHeight = 50
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
    }

    private func setupPermittedActions() {

        // order of elements in important for UI.

        if node.type == "dir" {

            if location.mount.permissions.create_link {
                actions.append(.sendDownloadLink)
            }

            if location.mount.permissions.create_receiver {
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

            actions.append(.directoryInfo)

        } else {

            if location.mount.permissions.create_link {
                actions.append(.sendDownloadLink)
//                actions.append(.makeOffline)
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

}
