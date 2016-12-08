//
//  DeleteAlertViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 26/10/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class DeleteViewController: UITableViewController {

    // MARK: - Properties

    fileprivate var node: Node
    weak var delegate: DeleteViewControllerDelegate?

    // MARK: - Initializers and Deinitializers

    init(node: Node) {
        self.node = node
        super.init(nibName: nil, bundle: nil)
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
        setupViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.preferredContentSize.height = tableView.contentSize.height - 1
        super.viewWillAppear(animated)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return createCell(title: NSLocalizedString("Delete", comment: "Button title") ,
                          color: .red)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.onConfirmDeletion()
    }

    // MARK: - Helper Functions

    fileprivate func setupViews() {
        let headerView: UIView = {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
            view.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
            return view
        }()

        let message: UILabel = {
            let label = UILabel()
            label.textAlignment = .center
            if node.type == "file" {
                label.text = NSLocalizedString("Are you sure you want to delete this file?", comment: "Question for user")
            } else {
                label.text = NSLocalizedString("Are you sure you want to delete this folder?", comment: "Question for user")
            }
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

    fileprivate func createCell(title: String, color: UIColor) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: nil)
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = color
        cell.textLabel?.text = title
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18)
        return cell
    }
}
