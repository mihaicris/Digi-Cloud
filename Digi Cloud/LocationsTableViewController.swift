//
//  LocationTableTableViewController.swift
//  test
//
//  Created by Mihai Cristescu on 15/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class LocationsTableViewController: UITableViewController {

    // MARK: - Properties

    var mounts: [Mount] = []

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Locations"

        tableView.register(LocationCell.self, forCellReuseIdentifier: "LocationCell")
        tableView.rowHeight = 78
        tableView.tableFooterView = UIView()
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        tableView.cellLayoutMarginsFollowReadableWidth = false

        DigiClient.shared.getLocations() { (mounts, error) in
            guard error == nil else {
                print("Error: \(error?.localizedDescription)")
                return
            }
            if let mounts = mounts  {
                self.mounts = mounts
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }

    // MARK: - Navigation

    func openMount(index: Int) {
        let controller = FilesTableViewController()
        DigiClient.shared.currentMount = mounts[index].id
        DigiClient.shared.currentPath.append("/")
        controller.title = mounts[index].name
        navigationController?.pushViewController(controller, animated: true)
    }

    // MARK: - Table View Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mounts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell") as! LocationCell
        cell.locationLabel.text = mounts[indexPath.row].name
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        openMount(index: indexPath.row)
    }

    #if DEBUG
    deinit { print("LocationsTableViewController deinit") }
    #endif
}

class LocationCell: UITableViewCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .blue
        accessoryType = .disclosureIndicator

        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let locationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Helvetica", size: 30)
        return label
    }()

    func setupViews() {

        contentView.addSubview(locationLabel)

        contentView.addConstraints(with: "H:|-15-[v0]|", views: locationLabel)
        contentView.addConstraints(with: "V:|[v0]|", views: locationLabel)
        
    }
    
}

