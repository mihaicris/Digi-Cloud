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

    let location: Location

    let onFinish: (() -> Void)

    // MARK: - Initializers and Deinitializers

    init(location: Location, onFinish: @escaping () -> Void) {
        self.location = location
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
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setToolbarHidden(true, animated: false)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.bounds.height / 3

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = ShareTableViewCell()
        cell.selectionStyle = .none

        switch indexPath.row {
        case 0:
            cell.nameLabel.text = NSLocalizedString("Send Link", comment: "")
        case 1:
            cell.nameLabel.text = NSLocalizedString("Receive Files", comment: "")
        case 2:
            cell.nameLabel.text = NSLocalizedString("Share in Digi Storage", comment: "")
        default:
            fatalError("Wrong cell index received")
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
            
        case 0:
            let controller = ShareLinkViewController(location: self.location, linkType: .download, onFinish: self.onFinish)
            self.navigationController?.pushViewController(controller, animated: true)
        case 1:
            let controller = ShareLinkViewController(location: self.location, linkType: .upload, onFinish: self.onFinish)
            self.navigationController?.pushViewController(controller, animated: true)
        case 2:
            let controller = SharePermissionsTableViewController(location: self.location, onFinish: self.onFinish)
            self.navigationController?.pushViewController(controller, animated: true)
        default:
            fatalError("Wrong index received.")
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

    @objc private func handleCancel() {
        onFinish()
    }

}
