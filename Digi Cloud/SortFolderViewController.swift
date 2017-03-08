//
//  SortFolderViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 07/11/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

final class SortFolderViewController: UITableViewController {

    // MARK: - Properties

    var onSelection: (() -> Void)?
    private var sortingActions: [String] = []

    // MARK: - Initializers and Deinitializers

    init() {
        super.init(style: .plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit { DEINITLog(self) }

    // MARK: - Overridden Methods and Properties

    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
        setupViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.preferredContentSize.height = tableView.contentSize.height - 1
        self.preferredContentSize.width = 250
        super.viewWillAppear(animated)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortingActions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // check if user selected the same sort method
        if  indexPath.row == AppSettings.sortMethod.rawValue {
            sortingActions[indexPath.row] += AppSettings.sortAscending ? "   ↑" : "   ↓"
        }

        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = sortingActions[indexPath.row]

        if indexPath.row == 0 {

            cell.selectionStyle = .none
            cell.textLabel?.textColor = UIColor.darkGray

            let switchButton = UISwitch()
            switchButton.addTarget(self, action: #selector(handleOnSwitchValueChanged(_:)), for: .valueChanged)
            switchButton.translatesAutoresizingMaskIntoConstraints = false

            if AppSettings.sortMethod == .bySize || AppSettings.sortMethod == .byContentType {
                switchButton.isOn = true
                switchButton.isEnabled = false
            } else {
                switchButton.isOn = AppSettings.showsFoldersFirst
            }

            cell.contentView.addSubview(switchButton)

            NSLayoutConstraint.activate([
                switchButton.rightAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.rightAnchor),
                switchButton.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
            ])

        } else {
            cell.textLabel?.textColor = .defaultColor
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath.row != 0 {
            setupActions()
            if indexPath.row == AppSettings.sortMethod.rawValue {
                // user changed the sort direction for the same method
                AppSettings.sortAscending = !AppSettings.sortAscending
            } else {
                // user changed the sort method
                AppSettings.sortMethod = SortMethodType(rawValue: indexPath.row)!
            }
            tableView.reloadData()
            onSelection?()
        }
    }

    // MARK: - Helper Functions

    private func setupViews() {

        let headerView: UIView = {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 50))
            view.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
            return view
        }()

        let titleName: UILabel = {
            let label = UILabel()
            label.text = NSLocalizedString("Sort directory", comment: "")
            label.font = UIFont.systemFont(ofSize: 14)
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()

        let separator: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor(white: 0.8, alpha: 1)
            return view
        }()

        headerView.addSubview(titleName)
        titleName.centerXAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true
        titleName.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true

        headerView.addSubview(separator)
        headerView.addConstraints(with: "H:|[v0]|", views: separator)
        headerView.addConstraints(with: "V:[v0(\(1 / UIScreen.main.scale))]|", views: separator)

        tableView.isScrollEnabled = false
        tableView.rowHeight = AppSettings.tableViewRowHeight
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
    }

    private func setupActions() {
        sortingActions = [
            NSLocalizedString("Directories first", comment: ""),
            NSLocalizedString("Sort by Name", comment: ""),
            NSLocalizedString("Sort by Date", comment: ""),
            NSLocalizedString("Sort by Size", comment: ""),
            NSLocalizedString("Sort by Type", comment: "")
        ]
    }

    @objc private func handleOnSwitchValueChanged(_ sender: UISwitch) {
        AppSettings.showsFoldersFirst = sender.isOn
        self.onSelection?()
    }

}
