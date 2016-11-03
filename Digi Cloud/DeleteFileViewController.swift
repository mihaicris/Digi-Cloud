//
//  DeleteViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 26/10/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class DeleteFileViewController: UITableViewController {

    var onFinish: ((_ success: Bool) -> Void)?

    fileprivate var element: File

    init(element: File) {
        self.element = element
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    fileprivate func setupViews() {
        let headerView: UIView = {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
            view.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
            return view
        }()

        let message: UILabel = {
            let label = UILabel()
            label.textAlignment = .center
            label.text = NSLocalizedString("Are you sure you want to delete this file?", comment: "Message")
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
        headerView.addConstraints(with: "V:[v0(\(1/UIScreen.main.scale))]|", views: separator)

        tableView.isScrollEnabled = false
        tableView.rowHeight = 50
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.preferredContentSize.height = tableView.contentSize.height - 1

    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return createCell(title: "Delete", color: .red)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        handleDelete()
    }

    private func createCell(title: String, color: UIColor) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: nil)
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = color
        cell.textLabel?.text = title
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18)
        return cell
    }

    @objc fileprivate func handleDelete() {

        // TODO Show on screen spinner for rename request

        //build the path of element to be renamed
        let elementPath = DigiClient.shared.currentPath.last! + element.name

        // network request for rename
        DigiClient.shared.delete(path: elementPath, name: element.name) { (statusCode, error) in

            // TODO: Stop spinner

            guard error == nil else {
                // TODO Show message for error
                print(error!.localizedDescription)
                return
            }
            if let code = statusCode {
                switch code {
                case 200:
                    // Delete successfully completed
                    self.onFinish?(true)
                case 400:
                    // TODO: Alert Bad Request
                    self.onFinish?(false)
                case 404:
                    // File not found, folder will be refreshed
                    self.onFinish?(false)
                default :
                    // TODO: Alert Status Code server
                    self.onFinish?(false)
                    return
                }
            }
        }
    }
    
    #if DEBUG
    deinit { print("DeleteFileViewController deinit") }
    #endif
}
