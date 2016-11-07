//
//  FolderInfoViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 02/11/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class FolderInfoViewController: UITableViewController {
    var onFinish: (() -> Void)?

    fileprivate var element: File
    fileprivate var rightBarButton: UIBarButtonItem!
    fileprivate var messageLabel: UILabel!

    init(element: File) {
        self.element = element
        super.init(style: .grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        updateFolderSize()
    }

    fileprivate func updateFolderSize() {
        //build the path of element to be renamed
        let elementPath = DigiClient.shared.currentPath.last! + element.name

        DigiClient.shared.getFolderSize(path: elementPath, completionHandler: { (size, error) in
            print(size ?? "nil")
        })

    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none

        return cell
    }

    fileprivate func setupViews() {

        messageLabel = {
            let label = UILabel()
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 14)
            label.textColor = .darkGray
            label.alpha = 0.0
            return label
        }()

        tableView.addSubview(messageLabel)
        tableView.addConstraints(with: "V:|-100-[v0]|", views: messageLabel)
        tableView.centerXAnchor.constraint(equalTo: messageLabel.centerXAnchor).isActive = true
        tableView.isScrollEnabled = false

        rightBarButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(handleDone))

        self.navigationItem.setRightBarButton(rightBarButton, animated: false)

        self.title = NSLocalizedString("Folder information", comment: "Title")
    }

    @objc fileprivate func handleDone() {
        onFinish?()
    }

    @objc fileprivate func handleDelete() {

    }

    #if DEBUG
    deinit {
        print("FolderInfoViewController deinit")
    }
    #endif
}
