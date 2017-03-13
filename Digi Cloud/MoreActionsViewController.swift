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

    private let location: Location
    private let node: Node

    private var moreActions: [ActionType] = []

    // MARK: - Initializers and Deinitializers

    init(location: Location, node: Node) {
        self.location = location
        self.node = node
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
        preferredContentSize.width = 250
        preferredContentSize.height = tableView.contentSize.height - 1
        super.viewWillAppear(animated)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moreActions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch moreActions[indexPath.row] {

        case .bookmark:
            let title = self.node.bookmark == nil
                ? NSLocalizedString("Set Bookmark", comment: "")
                : NSLocalizedString("Remove Bookmark", comment: "")
            return createCell(title: title, color: .defaultColor)

        case .createDirectory:
            return createCell(title: NSLocalizedString("Create Directory", comment: ""), color: .defaultColor)

        case .selectionMode:
            return createCell(title: NSLocalizedString("Select Mode", comment: ""), color: .defaultColor)

        case .share:
            return createCell(title: NSLocalizedString("Share", comment: ""), color: .defaultColor)

        default:
            return UITableViewCell()
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        self.dismiss(animated: true) {
            self.onSelect?(self.moreActions[indexPath.row])
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

    private func createCell(title: String, color: UIColor) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.textAlignment = .left
        cell.textLabel?.textColor = color
        cell.textLabel?.text = title
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        return cell
    }

    private func setupActions() {

        if location.mount.permissions.create_link || location.mount.permissions.create_receiver || location.mount.permissions.mount {
            moreActions.append(.share)
        }

        moreActions.append(.bookmark)

        if location.mount.canWrite {
            moreActions.append(.createDirectory)
        }

        moreActions.append(.selectionMode)
    }
}
