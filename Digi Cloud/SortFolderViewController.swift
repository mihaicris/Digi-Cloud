//
//  SortFolderViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 07/11/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class SortFolderViewController: UITableViewController, ActionCellDelegate {

    var onFinish: ((_ selection: Int) -> Void)?

    var contextMenuSortActions: [ActionCell] = []

    init() {
        super.init(style: .plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        self.preferredContentSize.height = tableView.contentSize.height - 1
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    fileprivate func setupViews() {
        let sortActions = [ActionCell(title: NSLocalizedString("Show folders first", comment: "Switch Title"),    tag: 0, switchDelegate: self),
                           ActionCell(title: NSLocalizedString("Sort by name",       comment: "Selection Title"), tag: 1                      ),
                           ActionCell(title: NSLocalizedString("Sort by size",       comment: "Selection Title"), tag: 2                      ),
                           ActionCell(title: NSLocalizedString("Sort by type",       comment: "Selection Title"), tag: 3                      )]

        // get from settings if sorted list has folders first
        if let button = sortActions[0].switchButton {
            button.isOn = UserDefaults.standard.getShowFoldersFirst()
        }

        contextMenuSortActions.append(contentsOf: sortActions)

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
        headerView.addConstraints(with: "V:[v0(\(1/UIScreen.main.scale))]|", views: separator)

        tableView.isScrollEnabled = false
        tableView.rowHeight = 50
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
    }

    func onSwitchValueChanged(button: UISwitch, value: Bool) {
        if button.tag == 0 {
            UserDefaults.standard.setShowFoldersFirst(value: value)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contextMenuSortActions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = contextMenuSortActions[indexPath.row]
        if cell.tag == 0 {
            cell.selectionStyle = .none
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let tag = tableView.cellForRow(at: indexPath)?.tag {
            if tag != 0 {
                self.onFinish?(tag)
            }
        }
    }
    
    #if DEBUG
    deinit { print("SortFolderViewController deinit") }
    #endif
}
