//
//  LocationsViewController.swift
//  test
//
//  Created by Mihai Cristescu on 15/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

final class LocationsViewController: UITableViewController {

    // MARK: - Properties

    enum SectionType: Int {
        case main
        case connections
        case imports
        case exports
    }

    var onFinish: (() -> Void)?

    private var mainMounts: [Mount] = [] {
        didSet {
            if !mainMounts.isEmpty { sections.append(.main) }
        }
    }

    private var connectionMounts: [Mount] = [] {
        didSet {
            if !connectionMounts.isEmpty { sections.append(.connections) }

        }
    }

    private var importMounts: [Mount] = [] {
        didSet {
            if !importMounts.isEmpty { sections.append(.imports) }
        }
    }

    private var exportMounts: [Mount] = [] {
        didSet {
            if !exportMounts.isEmpty { sections.append(.exports) }
        }
    }

    private var sections: [SectionType] = []

    // When coping or moving files/directories, this property will hold the source location which is passed between
    // controllers on navigation stack.
    private var sourceLocations: [Location]?

    private let action: ActionType
    private var isUpdating: Bool = false

    let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView()
        ai.hidesWhenStopped = true
        ai.activityIndicatorViewStyle = .gray
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()

    // MARK: - Initializers and Deinitializers

    init(action: ActionType, sourceLocations: [Location]? = nil) {
        self.action = action
        self.sourceLocations = sourceLocations
        super.init(style: .grouped)
        INITLog(self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit { DEINITLog(self) }

    // MARK: - Overridden Methods and Properties

    override func viewDidLoad() {
        setupNavigationBar()
        setupActivityIndicatorView()
        setupTableView()
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        self.getMounts()
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        DigiClient.shared.task?.cancel()
        super.viewWillDisappear(animated)
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

        let bookmarkButton = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(handleShowBookmarksViewController(_:)))

        navigationItem.setRightBarButton(bookmarkButton, animated: false)

        if action == .copy || action == .move {
            self.navigationItem.prompt = NSLocalizedString("Choose a destination", comment: "")
            let rightButton = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: ""),
                    style: .plain,
                    target: self,
                    action: #selector(handleDone))
            navigationItem.setRightBarButton(rightButton, animated: false)

        } else {
            let settingsButton = UIBarButtonItem(image: UIImage(named: "Settings-Icon"), style: .plain, target: self, action: #selector(handleShowSettings))
            self.navigationItem.setLeftBarButton(settingsButton, animated: false)
        }
        self.title = NSLocalizedString("Locations", comment: "")
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

    private func getMounts() {

        isUpdating = true

        DigiClient.shared.getMounts { mountsList, error in

            self.isUpdating = false

            guard error == nil else {

                var message: String

                switch error! {
                case NetworkingError.internetOffline(let msg):
                    message = msg
                case NetworkingError.requestTimedOut(let msg):
                    message = msg
                default:
                    message = NSLocalizedString("There was an error while refreshing the locations.", comment: "")
                }

                let title = NSLocalizedString("Error", comment: "")

                self.endRefreshAndReloadTable {
                    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""),
                            style: .default,
                            handler: nil))

                    self.present(alertController, animated: true, completion: nil)
                }

                return
            }

            var mounts = mountsList ?? []

            // Remove from list the mounts for which there isn't permission to write to (only in copy / move action). Or to our own export mounts....
            if self.action == .copy || self.action == .move {
                mounts = mounts.filter { $0.canWrite && $0.type != "export" }
            }

            self.sections.removeAll()

            self.mainMounts       = mounts.filter { $0.type == "device" && $0.isPrimary }
            self.connectionMounts = mounts.filter { $0.type == "device" && !$0.isPrimary }
            self.importMounts     = mounts.filter { $0.type == "import" }
            self.exportMounts     = mounts.filter { $0.type == "export" }

            if self.refreshControl?.isRefreshing == true {
                if self.tableView.isDragging {
                    return
                } else {
                    self.endRefreshAndReloadTable(completion: nil)
                }
            } else {
                self.tableView.reloadData()
            }
        }
    }

    private func endRefreshAndReloadTable(completion: (() -> Void)?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.refreshControl?.endRefreshing()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.tableView.reloadData()
                completion?()
            }
        }
    }

    @objc private func handleRefreshLocations() {
        if self.isUpdating {
            self.refreshControl?.endRefreshing()
            return
        }
        self.getMounts()
    }

    @objc private func handleShowSettings() {
        let controller = SettingsViewController(style: .grouped)
        let navController = UINavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .popover
        navController.popoverPresentationController?.barButtonItem = navigationItem.leftBarButtonItem
        present(navController, animated: true, completion: nil)
    }

    @objc private func handleShowBookmarksViewController(_ sender: UIBarButtonItem) {

        guard let buttonView = sender.value(forKey: "view") as? UIView else {
            return
        }

        let controller = ManageBookmarksViewController()

        controller.onSelect = { [weak self] location in
            let controller = ListingViewController(location: location, action: .noAction)
            self?.navigationController?.pushViewController(controller, animated: true)
        }

        let navController = UINavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .popover
        navController.popoverPresentationController?.sourceView = buttonView
        navController.popoverPresentationController?.sourceRect = buttonView.bounds
        present(navController, animated: true, completion: nil)
    }

    @objc private func handleDone() {
        dismiss(animated: true) {
            self.onFinish?()
        }
    }

    // MARK: TableView delegates

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        guard let sectionType = SectionType(rawValue: section) else {
            return 0
        }

        switch sectionType {
        case .main:
            return mainMounts.count
        case .connections:
            return connectionMounts.count
        case .imports:
            return importMounts.count
        case .exports:
            return exportMounts.count
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionType = SectionType(rawValue: section) else {
            return nil
        }

        switch sectionType {
        case .main:
            return mainMounts.isEmpty       ? nil : NSLocalizedString("Main storage", comment: "")
        case .connections:
            return connectionMounts.isEmpty ? nil : NSLocalizedString("Connections", comment: "")
        case .imports:
            return importMounts.isEmpty     ? nil : NSLocalizedString("Shared with you", comment: "")
        case .exports:
            return exportMounts.isEmpty     ? nil : NSLocalizedString("Shared by you", comment: "")
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell") as? LocationCell else {
            return UITableViewCell()
        }

        guard let sectionType = SectionType(rawValue: indexPath.section) else {
            return cell
        }

        var mount: Mount
        switch sectionType {
        case .main:
            mount = mainMounts[indexPath.row]
        case .connections:
            mount = connectionMounts[indexPath.row]
        case .imports:
            mount = importMounts[indexPath.row]
        case .exports:
            mount = exportMounts[indexPath.row]
        }

        cell.mount = mount
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard let cell = tableView.cellForRow(at: indexPath) as? LocationCell else {
            return
        }

        let location = Location(mount: cell.mount, path: "/")
        let controller = ListingViewController(location: location, action: self.action, sourceLocations: self.sourceLocations)

        if self.action != .noAction {
            controller.onFinish = { [weak self] in
                self?.onFinish?()
            }
        }
        navigationController?.pushViewController(controller, animated: true)
    }

    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if refreshControl?.isRefreshing == true {
            if self.isUpdating {
                return
            }
            self.endRefreshAndReloadTable(completion: nil)
        }
    }
}
