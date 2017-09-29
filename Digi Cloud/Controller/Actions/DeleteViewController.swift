//
//  DeleteViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 26/10/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

final class DeleteViewController: UITableViewController {

    // MARK: - Properties

    var onSelection: ( () -> Void)?

    private let isFolder: Bool

    // MARK: - Initializers and Deinitializers

    init(isFolder: Bool) {
        self.isFolder = isFolder
        super.init(nibName: nil, bundle: nil)
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
        setupViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.preferredContentSize.width = 350
        self.preferredContentSize.height = tableView.contentSize.height - 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: nil)
        cell.selectionStyle = .blue
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)

        if indexPath.row == 1 {
            cell.textLabel?.textColor = .defaultColor
            cell.textLabel?.text = NSLocalizedString("Cancel", comment: "")

        } else {
            cell.textLabel?.textColor = .red
            cell.textLabel?.text = NSLocalizedString("Delete", comment: "")
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: false) {
            if indexPath.row == 0 {
                self.onSelection?()
            }
        }
    }

    // MARK: - Helper Functions

    private func registerForNotificationCenter() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDismiss),
            name: .UIApplicationWillResignActive,
            object: nil)
    }

    private func setupViews() {
        let headerView: UIView = {
            let v = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
            v.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
            return v
        }()

        let message: UILabel = {
            let l = UILabel()
            l.textAlignment = .center
            if isFolder {
                l.text = NSLocalizedString("Are you sure you want to delete this folder?", comment: "")
            } else {
                l.text = NSLocalizedString("Are you sure you want to delete this file?", comment: "")
            }
            l.font = UIFont.systemFont(ofSize: 14)
            return l
        }()

        let separator: UIView = {
            let v = UIView()
            v.backgroundColor = UIColor(white: 0.8, alpha: 1)
            return v
        }()

        headerView.addSubview(message)
        headerView.addConstraints(with: "H:|-10-[v0]-10-|", views: message)
        message.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true

        headerView.addSubview(separator)
        headerView.addConstraints(with: "H:|[v0]|", views: separator)
        headerView.addConstraints(with: "V:[v0(\(1 / UIScreen.main.scale))]|", views: separator)

        self.title = NSLocalizedString("Delete confirmation", comment: "")

        tableView.isScrollEnabled = false
        tableView.tableHeaderView = headerView
        tableView.rowHeight = AppSettings.tableViewRowHeight
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
    }

    @objc private func handleDismiss() {
        self.dismiss(animated: false, completion: nil)
    }

}
