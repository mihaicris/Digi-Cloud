//
//  SortFolderViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 07/11/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class SortFolderViewController: UITableViewController {

    // MARK: - Properties

    var onFinish: ((_ dismiss: Bool) -> Void)?
    var contextMenuSortActions: [String] = []

    // MARK: - Initializers and Deinitializers

    init() {
        super.init(style: .plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    #if DEBUG
    deinit {
        print("[DEINIT]: " + String(describing: type(of: self)))
    }
    #endif

    // MARK: - Overridden Methods and Properties

    override func viewDidLoad() {
        super.viewDidLoad()
        setInitialActionNames()
        setupViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.preferredContentSize.height = tableView.contentSize.height - 1
        self.preferredContentSize.width = 250
        super.viewWillAppear(animated)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contextMenuSortActions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sortMethodRow = indexPath.row

        // check if user selected the same sort method
        if  sortMethodRow == AppSettings.sortMethod.rawValue {
            contextMenuSortActions[sortMethodRow] += AppSettings.sortAscending ? "   ↑" : "   ↓"
        }

        guard let action = ActionType(rawValue: sortMethodRow) else { return UITableViewCell() }

        let cell = ActionCell(title: contextMenuSortActions[sortMethodRow], action: action)
        if sortMethodRow == 0 {
            cell.delegate = self
            cell.selectionStyle = .none
            if AppSettings.sortMethod == .bySize || AppSettings.sortMethod == .byContentType {
                cell.switchButton.isOn = true
                cell.switchButton.isEnabled = false
            } else {
                cell.switchButton!.isOn = AppSettings.showFoldersFirst
            }
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ActionCell {
            let tag = cell.tag
            if tag != 0 {
                setInitialActionNames()
                if tag == AppSettings.sortMethod.rawValue {
                    // user changed the sort direction for the same method
                    AppSettings.sortAscending = !AppSettings.sortAscending
                } else {
                    // user changed the sort method
                    AppSettings.sortMethod = SortMethodType(rawValue: tag)!
                }
                tableView.reloadData()
                self.onFinish?(true)
            }
        }
    }

    // MARK: - Helper Functions

    fileprivate func setInitialActionNames() {
        contextMenuSortActions = [
            NSLocalizedString("Folders first", comment: "Switch Title"),
            NSLocalizedString("Sort by Name",  comment: "Selection Title"),
            NSLocalizedString("Sort by Date",  comment: "Selection Title"),
            NSLocalizedString("Sort by Size",  comment: "Selection Title"),
            NSLocalizedString("Sort by Type",  comment: "Selection Title") ]
    }

    fileprivate func setupViews() {

        let headerView: UIView = {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 50))
            view.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
            return view
        }()

        let titleName: UILabel = {
            let label = UILabel()
            label.text = NSLocalizedString("Sort folder", comment: "Window Title")
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
}

extension SortFolderViewController: ActionCellDelegate {
    func onSwitchValueChanged(button: UISwitch, value: Bool) {
        if button.tag == 0 {
            AppSettings.showFoldersFirst = value
            self.onFinish?(false)
        }
    }
}
