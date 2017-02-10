//
//  MoreActionsViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 02/02/2017.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import UIKit

enum MoreActions: Int {
    case createDirectory
    case selectionMode
}

class MoreActionsViewController: UITableViewController {

    // MARK: - Properties

    var onFinish: ((MoreActions) -> Void)?
    private var contextMenuSortActions: [String] = []

    // MARK: - Initializers and Deinitializers

    #if DEBUG_CONTROLLERS
    deinit {
        print("[DEINIT]: " + String(describing: type(of: self)))
    }
    #endif

    // MARK: - Overridden Methods and Properties

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        preferredContentSize.width = 250
        preferredContentSize.height = tableView.contentSize.height - 1
        super.viewWillAppear(animated)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return createCell(title: NSLocalizedString("Create Directory", comment: ""), color: .defaultColor)
        } else {
            return createCell(title: NSLocalizedString("Select Mode", comment: ""), color: .defaultColor)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard let selection = MoreActions(rawValue: indexPath.row) else { return }

        onFinish?(selection)
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
}
