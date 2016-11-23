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

    var onFinish: (() -> Void)?
    var mounts: [Mount] = []
    private let action: ActionType

    // MARK: - Initializers and Deinitializers

    init(action: ActionType) {
        self.action = action
        super.init(style: .grouped)
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
        setupNavigationBar()
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

    private func setupNavigationBar() {
        // Create navigation elements when coping or moving

        if action == .copy || action == .move {
            self.navigationItem.prompt = NSLocalizedString("Choose a destination", comment: "Window prompt")
            let rightButton = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: "Button Title"), style: .plain, target: self, action: #selector(handleDone))

            navigationItem.setRightBarButton(rightButton, animated: false)
        }
        self.title = NSLocalizedString("Locations", comment: "Window Title")
    }

    private func setupTableView() {
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

    private func openMount(index: Int) {
        let location = Location(mount: mounts[index] , path: "/")

        let controller = ListingViewController(action: self.action, for: location, node: nil)
        controller.title = mounts[index].name
        controller.onFinish = { [unowned self] in
            self.dismiss(animated: true, completion: nil)
        }

        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc private func handleDone() {
        self.onFinish?()
    }
}

