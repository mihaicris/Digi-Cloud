//
//  LocationsViewController.swift
//  test
//
//  Created by Mihai Cristescu on 15/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class LocationsViewController: UITableViewController {

    // MARK: - Properties

    var onFinish: (() -> Void)?

    private var locations: [Location] = []
    private let action: ActionType
    private var isUpdating: Bool = false

    let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView()
        ai.hidesWhenStopped = true
        ai.activityIndicatorViewStyle = .gray
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()

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
        setupActivityIndicatorView()
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

    private func setupActivityIndicatorView() {
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -44)
        ])
    }

    private func setupNavigationBar() {

        // Create navigation elements when coping or moving
        if action == .copy || action == .move {
            self.navigationItem.prompt = NSLocalizedString("Choose a destination", comment: "Window prompt")
            let rightButton = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: "Button Title"),
                                              style: .plain,
                                              target: self,
                                              action: #selector(handleDone))

            navigationItem.setRightBarButton(rightButton, animated: false)
        } else {
            let settingsButton = UIBarButtonItem(image: UIImage(named: "Settings-Icon"), style: .plain, target: self, action: #selector(handleShowSettings))
            self.navigationItem.setLeftBarButton(settingsButton, animated: false)
        }
        self.title = NSLocalizedString("Locations", comment: "Window Title")
    }

    private func setupTableView() {
        tableView.register(LocationCell.self, forCellReuseIdentifier: "LocationCell")
        tableView.rowHeight = 78
        tableView.tableFooterView = UIView()
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        tableView.cellLayoutMarginsFollowReadableWidth = false
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(handleRefreshLocations), for: UIControlEvents.valueChanged)
    }

    private func getLocations() {

        self.isUpdating = true

        DigiClient.shared.getDIGIStorageLocations { locations, error in

            self.isUpdating = false

            guard error == nil else {
                print("Error: \(error!.localizedDescription)")
                self.endRefreshAndReloadTable()
                let message = NSLocalizedString("There was an error refreshing the locations.", comment: "Notice")
                let title = NSLocalizedString("Error", comment: "Title")
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
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

    private func openMount(index: Int) {
        let controller = ListingViewController(action: self.action, for: locations[index])
        controller.title = locations[index].mount.name
        if self.action != .noAction {
            controller.onFinish = { [unowned self] in
                self.onFinish?()
            }
        }
        navigationController?.pushViewController(controller, animated: true)
    }

    private func endRefreshAndReloadTable() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.refreshControl?.endRefreshing()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.tableView.reloadData()
            }
        }
    }

    @objc private func handleRefreshLocations() {
        if self.isUpdating {
            self.refreshControl?.endRefreshing()
            return
        }
        self.getLocations()
    }

    @objc private func handleShowSettings() {
        let controller = SettingsViewController(style: .grouped)
        let navController = UINavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .popover
        navController.popoverPresentationController?.barButtonItem = navigationItem.leftBarButtonItem
        present(navController, animated: true, completion: nil)
    }

    @objc private func handleDone() {
        self.onFinish?()
    }
}
