//
//  SortFolderViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 07/11/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class SortFolderViewController: UITableViewController, ActionCellDelegate {

    var onFinish: ((_ dismiss: Bool) -> Void)?

    var contextMenuSortActions: [ActionCell] = []

    init() {
        super.init(style: .plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        self.preferredContentSize.height = tableView.contentSize.height - 1
        self.preferredContentSize.width = 250
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    fileprivate func setupViews() {
        contextMenuSortActions = [ActionCell(title: NSLocalizedString("Folders first", comment: "Switch Title"),    tag: 0, switchDelegate: self),
                           ActionCell(title: NSLocalizedString("Sort by name",  comment: "Selection Title"), tag: 1                      ),
                           ActionCell(title: NSLocalizedString("Sort by date",  comment: "Selection Title"), tag: 2                      ),
                           ActionCell(title: NSLocalizedString("Sort by size",  comment: "Selection Title"), tag: 3                      ),
                           ActionCell(title: NSLocalizedString("Sort by type",  comment: "Selection Title"), tag: 4                      )
                           ]

        // get from settings if sorted list has folders first
        if let button = contextMenuSortActions[0].switchButton {
            button.isOn = AppSettings.showFoldersFirst
        }

        let selectedCell = contextMenuSortActions[AppSettings.sortMethod.rawValue]
        selectedCell.textLabel!.text! += AppSettings.sortAscending ? "  ↑" : "  ↓"

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
            AppSettings.showFoldersFirst = value
            self.onFinish?(false)
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
                if tag == AppSettings.sortMethod.rawValue {
                    // user selected the same sort method, thus it changed sorting direction
                    AppSettings.sortAscending = !AppSettings.sortAscending
                    let selectedCell = contextMenuSortActions[tag]
                    let title = String(selectedCell.textLabel!.text!.characters.dropLast(2))
                    selectedCell.textLabel!.text! = AppSettings.sortAscending ? "\(title) ↑" : "\(title) ↓"
                }
                // user changed the sort method
                switch tag {
                case 1:
                    AppSettings.sortMethod = .byName
                case 2:
                    AppSettings.sortMethod = .byDate
                case 3:
                    AppSettings.sortMethod = .bySize
                case 4:
                    AppSettings.sortMethod = .byContentType
                default:
                    break
                }
                self.onFinish?(true)

            }
        }
    }
    
    #if DEBUG
    deinit { print("SortFolderViewController deinit") }
    #endif
}
