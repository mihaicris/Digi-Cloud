//
//  ShareViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 02/03/2017.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import UIKit

final class ShareViewController: UITableViewController {

    // MARK: - Properties

    var location: Location

    var sharedNode: Node

    var sharingActions: [ActionType] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    let onFinish: ((_ shouldExitMount: Bool) -> Void)

    // MARK: - Initializers and Deinitializers

    init(location: Location, sharedNode: Node, onFinish: @escaping (Bool) -> Void) {
        self.location = location
        self.sharedNode = sharedNode
        self.onFinish = onFinish
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overridden Methods and Properties

    override func viewDidLoad() {
        self.edgesForExtendedLayout = UIRectEdge.bottom
        setupTableView()
        setupViews()
        setupNavigationItems()
        setupActions()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setToolbarHidden(true, animated: false)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sharingActions.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.bounds.height / CGFloat(sharingActions.count)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = ShareTableViewCell()
        cell.selectionStyle = .none

        switch sharingActions[indexPath.row] {
        case .sendDownloadLink:
            cell.nameLabel.text = NSLocalizedString("Send Link", comment: "")
        case .sendUploadLink:
            cell.nameLabel.text = NSLocalizedString("Receive Files", comment: "")
        case .makeNewShare:
            cell.nameLabel.text = NSLocalizedString("Share in Digi Storage", comment: "")
        case .manageShare:
            cell.nameLabel.text = NSLocalizedString("Manage Share", comment: "")
        case .shareInfo:
            cell.nameLabel.text = NSLocalizedString("Share Information", comment: "")
        default:
            break
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch sharingActions[indexPath.row] {

        case .sendDownloadLink:
            let controller = ShareLinkViewController(location: self.location, linkType: .download, onFinish: self.onFinish)
            self.navigationController?.pushViewController(controller, animated: true)

        case .sendUploadLink:
            let controller = ShareLinkViewController(location: self.location, linkType: .upload, onFinish: self.onFinish)
            self.navigationController?.pushViewController(controller, animated: true)

        case .makeNewShare:
            let controller = ShareMountViewController(location: self.location, sharedNode: self.sharedNode, onFinish: self.onFinish)
            self.navigationController?.pushViewController(controller, animated: true)

        case .shareInfo:
            let controller = ShareMountViewController(location: self.location, sharedNode: self.sharedNode, onFinish: self.onFinish)
            self.navigationController?.pushViewController(controller, animated: true)

        default:
            break
        }
    }

    // MARK: - Helper Functions

    private func setupTableView() {

        tableView.separatorStyle = .none

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ShareTableViewCell.self, forCellReuseIdentifier: "ShareTableViewCellId")
    }

    private func setupViews() {

    }

    private func setupNavigationItems() {
        self.title = NSLocalizedString("Share Directory", comment: "")
        let cancelButton = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: ""), style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.setRightBarButton(cancelButton, animated: false)
    }

    func setupActions() {

        var actions: [ActionType] = []

        if location.mount.permissions.create_link {
            actions.append(.sendDownloadLink)
        }

        if location.mount.permissions.create_receiver {
            actions.append(.sendUploadLink)
        }

        if location.mount.permissions.mount {
            actions.append(.makeNewShare)
        }

        if !actions.contains(.makeNewShare) {
            actions.append(.shareInfo)
        }

        sharingActions = actions

    }

    @objc private func handleCancel() {
        dismiss(animated: true) {
            self.onFinish(false)
        }
    }

}
