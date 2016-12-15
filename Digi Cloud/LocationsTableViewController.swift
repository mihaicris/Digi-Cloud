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
    fileprivate var locations: [Location] = []
    fileprivate let action: ActionType
    fileprivate var isUpdating: Bool = false

    #if DEBUG
    let tag: Int
    #endif

    // MARK: - Initializers and Deinitializers

    init(action: ActionType) {
        self.action = action

        #if DEBUG
        count += 1
        self.tag = count
        print(self.tag, "✅", String(describing: type(of: self)), action)
        #endif

        super.init(style: .grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    #if DEBUG
    deinit {
        print(self.tag, "❌", String(describing: type(of: self)), action)
        count -= 1
    }
    #endif
    // MARK: - Overridden Methods and Properties

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getLocations()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell") as? LocationCell else {
            return UITableViewCell()
        }
        cell.locationLabel.text = locations[indexPath.row].mount.name
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        openMount(index: indexPath.row)
    }

    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if refreshControl?.isRefreshing == true {
            if self.isUpdating {
                return
            }
            self.endRefreshAndReloadTable()
        }
    }

    // MARK: - Helper Functions

    fileprivate func setupNavigationBar() {

        // Create navigation elements when coping or moving
        if action == .copy || action == .move {
            self.navigationItem.prompt = NSLocalizedString("Choose a destination", comment: "Window prompt")
            let rightButton = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: "Button Title"),
                                              style: .plain,
                                              target: self,
                                              action: #selector(handleDone))

            navigationItem.setRightBarButton(rightButton, animated: false)
        }
        self.title = NSLocalizedString("Locations", comment: "Window Title")
    }

    fileprivate func setupTableView() {
        tableView.register(LocationCell.self, forCellReuseIdentifier: "LocationCell")
        tableView.rowHeight = 78
        tableView.tableFooterView = UIView()
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        tableView.cellLayoutMarginsFollowReadableWidth = false
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(handleRefresh), for: UIControlEvents.valueChanged)
    }

    fileprivate func getLocations() {

        self.isUpdating = true

        DigiClient.shared.getDIGIStorageLocations() { locations, error in

            self.isUpdating = false

            guard error == nil else {
                print("Error: \(error!.localizedDescription)")
                return
            }
            if let locations = locations {
                self.locations = locations
            }
            if self.refreshControl?.isRefreshing == true {
                if self.tableView.isDragging {
                    return
                } else {
                    self.endRefreshAndReloadTable()
                }
            } else {
                self.tableView.reloadData()
            }
        }
    }

    fileprivate func openMount(index: Int) {
        let controller = ListingViewController(action: self.action, for: locations[index])
        controller.title = locations[index].mount.name
        if self.action != .noAction {
            controller.onFinish = { [unowned self] in
                self.onFinish?()
            }
        }
        navigationController?.pushViewController(controller, animated: true)
    }

    fileprivate func endRefreshAndReloadTable() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.refreshControl?.endRefreshing()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.tableView.reloadData()
            }
        }
    }

    @objc fileprivate func handleRefresh() {
        if self.isUpdating {
            self.refreshControl?.endRefreshing()
            return
        }
        self.getLocations()
    }

    @objc fileprivate func handleDone() {
        self.onFinish?()
    }
}
