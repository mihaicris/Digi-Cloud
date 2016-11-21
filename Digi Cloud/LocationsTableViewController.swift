//
//  LocationsTableViewController.swift
//  test
//
//  Created by Mihai Cristescu on 15/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class LocationsTableViewController: UITableViewController {

    // MARK: - Properties

    var mounts: [Mount] = []

    // MARK: - Initializers and Deinitializers

    #if DEBUG
    deinit {
        print("[DEINIT]: " + String(describing: type(of: self)))
    }
    #endif

    // MARK: - Overridden Methods and Properties

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        getLocations()
    }

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

    // MARK: - Helper Functions

    private func setupTableView() {
        self.title = NSLocalizedString("Locations", comment: "Window Title")
        tableView.register(LocationCell.self, forCellReuseIdentifier: "LocationCell")
        tableView.rowHeight = 78
        tableView.tableFooterView = UIView()
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        tableView.cellLayoutMarginsFollowReadableWidth = false
    }

    private func getLocations() {
        DigiClient.shared.getLocations() { (mounts, error) in
            guard error == nil else {
                print("Error: \(error!.localizedDescription)")
                return
            }
            if let mounts = mounts {
                self.mounts = mounts
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }

    func openMount(index: Int) {
        let controller = ListingViewController(mountID: mounts[index].id, path: "/", backButtonTitle: navigationItem.title!)
        controller.title = mounts[index].name
        navigationController?.pushViewController(controller, animated: true)
    }
}


