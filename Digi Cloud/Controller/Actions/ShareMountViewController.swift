//
//  ShareMountViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 02/03/2017.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import UIKit

final class ShareMountViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Properties

    var onFinish: ((_ exitMount: Bool) -> Void)?

    private let location: Location

    var sharedNode: Node

    private var mappingProfileImages: [String: UIImage] = [:]

    private var users: [User] = []

    private var isToolBarAlwaisHidden: Bool = false

    private var controllerShouldBeDismissed = false

    enum TableViewType: Int {
        case location = 0
        case users
    }

    private lazy var tableViewForLocation: UITableView = {
        let t = UITableView(frame: CGRect.zero, style: .grouped)
        t.translatesAutoresizingMaskIntoConstraints = false
        t.isUserInteractionEnabled = false
        t.delegate = self
        t.dataSource = self
        t.tag = TableViewType.location.rawValue
        return t
    }()

    private lazy var tableViewForUsers: UITableView = {
        let t = UITableView(frame: CGRect.zero, style: .plain)
        t.translatesAutoresizingMaskIntoConstraints = false
        t.alwaysBounceVertical = true
        t.delegate = self
        t.dataSource = self
        t.tag = TableViewType.users.rawValue
        t.register(MountUserCell.self, forCellReuseIdentifier: String(describing: MountUserCell.self))
        return t
    }()

    let usersLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = NSLocalizedString("MEMBERS", comment: "")
        l.font = UIFont(name: ".SFUIText", size: 12) ?? UIFont.HelveticaNeue(size: 12)
        l.textColor = UIColor(red: 0.43, green: 0.43, blue: 0.45, alpha: 1.0)
        return l
    }()

    private var errorMessageVerticalConstraint: NSLayoutConstraint?

    private lazy var waitingView: UIView = {

        let v = UIView()

        v.isHidden = false

        v.backgroundColor = .white
        v.translatesAutoresizingMaskIntoConstraints = false

        let spinner: UIActivityIndicatorView = {
            let s = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            s.translatesAutoresizingMaskIntoConstraints = false
            s.hidesWhenStopped = true
            s.tag = 55
            s.startAnimating()
            return s
        }()

        let okButton: UIButton = {
            let b = UIButton(type: UIButtonType.system)
            b.translatesAutoresizingMaskIntoConstraints = false
            b.setTitle(NSLocalizedString("OK", comment: ""), for: UIControlState.normal)
            b.setTitleColor(.white, for: .normal)
            b.layer.cornerRadius = 10
            b.contentEdgeInsets = UIEdgeInsets(top: 2, left: 40, bottom: 2, right: 40)
            b.sizeToFit()
            b.backgroundColor = UIColor(red: 0.7, green: 0.7, blue: 0.9, alpha: 1)
            b.tag = 11
            b.isHidden = false
            b.addTarget(self, action: #selector(handleHideWaitingView), for: .touchUpInside)
            return b
        }()

        let label: UILabel = {
            let l = UILabel()
            l.translatesAutoresizingMaskIntoConstraints = false
            l.textColor = .gray
            l.textAlignment = .center
            l.font = UIFont.systemFont(ofSize: 14)
            l.tag = 99
            l.numberOfLines = 0
            return l
        }()

        v.addSubview(spinner)
        v.addSubview(label)
        v.addSubview(okButton)

        self.errorMessageVerticalConstraint = label.centerYAnchor.constraint(equalTo: v.centerYAnchor, constant: 40)

        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: v.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: v.centerYAnchor),
            label.centerXAnchor.constraint(equalTo: v.centerXAnchor),
            label.widthAnchor.constraint(equalTo: v.widthAnchor, multiplier: 0.8),
            self.errorMessageVerticalConstraint!,
            okButton.centerXAnchor.constraint(equalTo: v.centerXAnchor),
            okButton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 40)
            ])

        return v
    }()

    // MARK: - Initializers and Deinitializers

    init(location: Location, sharedNode: Node, onFinish: @escaping (Bool) -> Void) {
        self.location = location
        self.sharedNode = sharedNode
        self.onFinish = onFinish
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit { DEINITLog(self) }

    // MARK: - Overridden Methods and Properties

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupNavigationItems()
        setupToolBarItems()
        configureWaitingView(type: .started, message: NSLocalizedString("Please wait...", comment: ""))
        if let mount = sharedNode.mount {
            if mount.root == nil && sharedNode.mountPath != "/" {
                createMount()
            } else {
                refreshMount()
            }
        } else {
            createMount()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isToolbarHidden = false
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        var headerTitle: String?

        guard let type = TableViewType(rawValue: tableView.tag) else {
            return headerTitle
        }

        switch type {
        case .location:
            headerTitle = NSLocalizedString("LOCATION", comment: "")
        case .users:
            break
        }
        return headerTitle
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        guard let type = TableViewType(rawValue: tableView.tag) else {
            return 0
        }

        switch type {
        case .location:
            return 35
        case .users:
            return 0.01
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        guard let type = TableViewType(rawValue: tableView.tag) else {
            return 0
        }

        switch type {
        case .location:
            return 1
        case .users:
            return users.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let type = TableViewType(rawValue: tableView.tag) else {
            return UITableViewCell()
        }

        switch type {
        case .location:

            let cell = UITableViewCell()
            cell.isUserInteractionEnabled = false
            cell.selectionStyle = .none

            let mountNameLabel: UILabelWithPadding = {
                let l = UILabelWithPadding(paddingTop: 1, paddingLeft: 5, paddingBottom: 2, paddingRight: 5)
                l.font = UIFont.HelveticaNeue(size: 12)
                l.adjustsFontSizeToFitWidth = true
                l.textColor = .darkGray
                l.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
                l.text = location.mount.name
                l.layer.cornerRadius = 4
                l.clipsToBounds = true
                l.translatesAutoresizingMaskIntoConstraints = false
                return l
            }()

            let locationPathLabel: UILabel = {
                let l = UILabel()
                l.translatesAutoresizingMaskIntoConstraints = false
                l.textColor = .darkGray
                l.text = String(location.path.characters.dropLast())
                l.numberOfLines = 2
                l.font = UIFont.HelveticaNeue(size: 12)
                l.lineBreakMode = .byTruncatingMiddle
                return l
            }()

            cell.contentView.addSubview(mountNameLabel)
            cell.contentView.addSubview(locationPathLabel)

            NSLayoutConstraint.activate([
                locationPathLabel.leftAnchor.constraint(equalTo: mountNameLabel.rightAnchor, constant: 2),
                locationPathLabel.rightAnchor.constraint(lessThanOrEqualTo : cell.contentView.layoutMarginsGuide.rightAnchor),
                locationPathLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),

                mountNameLabel.leftAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.leftAnchor),
                mountNameLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
                ])

            return cell

        case .users:

            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MountUserCell.self),
                                                           for: indexPath) as? MountUserCell else {
                return UITableViewCell()
            }

            let user = users[indexPath.row]
            cell.selectionStyle = .none

            if let owner = sharedNode.mount?.owner {
                if owner == user {
                    cell.isUserInteractionEnabled = false
                    cell.isOwner = true
                } else {
                    if  user.permissions.mount {
                        cell.accessoryType = .disclosureIndicator
                    }
                }
            }

            cell.user = user

            if let image = mappingProfileImages[users[indexPath.row].id] {
                cell.profileImageView.image = image
            } else {
                cell.profileImageView.image = #imageLiteral(resourceName: "account_icon")
            }

            return cell

        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: false)

        guard let mount = sharedNode.mount else {
            print("No valid mount in node for editing.")
            return
        }

        let user = users[indexPath.row]

        // Only owner can change permissions or user has mount management permission.
        guard mount.permissions.owner || user.permissions.mount else { return }

        let controller = AddMountUserViewController(mount: mount, user: user)

        controller.onUpdatedUser = { [weak self] in

            self?.refreshMount()
            _ = self?.navigationController?.popViewController(animated: true)
        }

        navigationController?.pushViewController(controller, animated: true)

    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            removeUser(at: indexPath)
        }
    }

    // MARK: - Helper Functions

    private func setupViews() {

        let headerView: UIImageView = {
            let iv = UIImageView(frame: CGRect.zero)
            iv.translatesAutoresizingMaskIntoConstraints = false
            iv.image = #imageLiteral(resourceName: "share_digi_background")
            iv.contentMode = .scaleAspectFill
            return iv
        }()

        view.addSubview(headerView)
        view.addSubview(tableViewForLocation)
        view.addSubview(tableViewForUsers)
        view.addSubview(usersLabel)
        view.addSubview(waitingView)

        NSLayoutConstraint.activate([

            waitingView.topAnchor.constraint(equalTo: view.topAnchor),
            waitingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            waitingView.leftAnchor.constraint(equalTo: view.leftAnchor),
            waitingView.rightAnchor.constraint(equalTo: view.rightAnchor),

            headerView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            headerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            headerView.rightAnchor.constraint(equalTo: view.rightAnchor),

            tableViewForLocation.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableViewForLocation.heightAnchor.constraint(equalToConstant: 115),
            tableViewForLocation.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableViewForLocation.rightAnchor.constraint(equalTo: view.rightAnchor),

            usersLabel.bottomAnchor.constraint(equalTo: tableViewForLocation.bottomAnchor, constant: -10),
            usersLabel.leftAnchor.constraint(equalTo: tableViewForLocation.layoutMarginsGuide.leftAnchor),

            tableViewForUsers.topAnchor.constraint(equalTo: tableViewForLocation.bottomAnchor),
            tableViewForUsers.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableViewForUsers.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableViewForUsers.rightAnchor.constraint(equalTo: view.rightAnchor)
            ])
    }

    private func setupNavigationItems() {

        title = NSLocalizedString("Members", comment: "")
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Back", comment: ""), style: .done, target: nil, action: nil)

        let doneButton = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: .done, target: self, action: #selector(handleDone))
        navigationItem.setRightBarButton(doneButton, animated: false)
    }

    private func setupToolBarItems() {

        var toolBarItems: [UIBarButtonItem] = []

        let flexibleButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)

        let addUserButton: UIBarButtonItem = {
            let v = UIButton(type: UIButtonType.system)
            v.setTitle(NSLocalizedString("Add member", comment: ""), for: .normal)
            v.addTarget(self, action: #selector(showAddUserView), for: .touchUpInside)
            v.setTitleColor(UIColor(white: 0.8, alpha: 1), for: .disabled)
            v.setTitleColor(UIColor.defaultColor, for: .normal)
            v.titleLabel?.font = UIFont.systemFont(ofSize: 18)
            v.sizeToFit()
            let b = UIBarButtonItem(customView: v)
            return b
        }()

        let removeShareButton: UIBarButtonItem = {
            let v = UIButton(type: UIButtonType.system)
            v.setTitle(NSLocalizedString("Remove Share", comment: ""), for: .normal)
            v.addTarget(self, action: #selector(handleRemoveMount), for: .touchUpInside)
            v.setTitleColor(UIColor(white: 0.8, alpha: 1), for: .disabled)
            v.setTitleColor(.red, for: .normal)
            v.titleLabel?.font = UIFont.systemFont(ofSize: 18)
            v.sizeToFit()
            let b = UIBarButtonItem(customView: v)
            return b
        }()

        if let mount = sharedNode.mount {

            // if no management mount permission, then hide alwais the toolbar which
            // can contains remove share and / or add member buttons.
            if !mount.permissions.mount {
                isToolBarAlwaisHidden = true
                return
            }

            if mount.type == "import" || (mount.type == "device" && sharedNode.mountPath == "/") {
                toolBarItems.append(contentsOf: [flexibleButton, addUserButton])
            } else {
                toolBarItems.append(contentsOf: [removeShareButton, flexibleButton, addUserButton])
            }
        } else {

            toolBarItems.append(contentsOf: [removeShareButton, flexibleButton, addUserButton])
        }

        setToolbarItems(toolBarItems, animated: false)

    }

    private func configureWaitingView(type: WaitingType, message: String) {

        switch type {
        case .hidden:
            waitingView.isHidden = true

            navigationController?.isToolbarHidden = isToolBarAlwaisHidden

        case .started, .stopped:
            waitingView.isHidden = false

            navigationController?.isToolbarHidden = true

            if let v = waitingView.viewWithTag(55) as? UIActivityIndicatorView,
                let b = waitingView.viewWithTag(11) as? UIButton {
                if type == .started {
                    v.startAnimating()
                    errorMessageVerticalConstraint?.constant = 40
                    b.isHidden = true
                } else {
                    v.stopAnimating()
                    b.isHidden = false
                    errorMessageVerticalConstraint?.constant = 0
                }
            }

            if let v = waitingView.viewWithTag(99) as? UILabel {
                v.text = message
            }
        }
    }

    private func createMount() {

        DigiClient.shared.createSubmount(at: self.location, withName: sharedNode.name) { mount, error in

            guard error == nil else {

                let errorMessage = NSLocalizedString("There was an error at share creation.", comment: "")

                self.configureWaitingView(type: .stopped, message: errorMessage)

                return
            }

            if let mount = mount {
                self.processMount(mount)
            }
        }
    }

    private func refreshMount() {

        controllerShouldBeDismissed = false

        guard let mount = sharedNode.mount else {
            return
        }

        DigiClient.shared.getMountDetails(for: mount) { mount, error in
            guard error == nil else {

                self.controllerShouldBeDismissed = true

                let errorMessage = NSLocalizedString("There was an error at requesting share information.", comment: "")

                self.configureWaitingView(type: .stopped, message: errorMessage)

                return
            }

            if let mount = mount {
                self.processMount(mount)
            }
        }
    }

    private func processMount(_ mount: Mount) {
        self.sharedNode.mount = mount
        self.setupToolBarItems()
        self.getUserProfileImages(for: mount.users)
    }

    private func getUserProfileImages(for someUsers: [User]) {

        let dispatchGroup = DispatchGroup()

        for user in someUsers {

            // if profile image already available, skip network request
            if mappingProfileImages[user.id] != nil {
                continue
            }

            dispatchGroup.enter()

            DigiClient.shared.getUserProfileImage(for: user) { image, error in

                dispatchGroup.leave()

                guard error == nil else {
                    return
                }

                if let image = image {
                    self.mappingProfileImages[user.id] = image
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            self.updateUsersModel(someUsers)
            self.tableViewForUsers.reloadData()
            self.configureWaitingView(type: .hidden, message: "")
        }
    }

    private func updateUsersModel(_ someUsers: [User]) {

        // if the user already exists in the users array replace it (maybe it has new permissions)
        // otherwise add it to the array
        for user in someUsers {

            if let index = users.index(of: user) {
                users[index] = user
            } else {
                users.append(user)
            }
        }
    }

    private func removeUser(at indexPath: IndexPath) {

        guard let mount = sharedNode.mount else {
            print("No valid mount for user addition.")
            return
        }

        let user = users[indexPath.row]

        DigiClient.shared.updateMount(mount: mount, operation: .remove, user: user) { _, error in

            guard error == nil else {
                self.configureWaitingView(type: .stopped, message: "There was an error while removing the member.")
                self.tableViewForUsers.isEditing = false
                return
            }

            self.users.remove(at: indexPath.row)

            // Remove from tableView
            self.tableViewForUsers.deleteRows(at: [indexPath], with: .automatic)

            // if the user is not owner and it is the last user, it means user has left the share.

            if DigiClient.shared.loggedAccount.userID == user.id {
                self.dismiss(animated: true) {
                    self.onFinish?(true)
                }
            }
        }
    }

    @objc private func showAddUserView() {

        guard let mount = sharedNode.mount else {
            print("No valid mount for user addition.")
            return
        }

        let controller = AddMountUserViewController(mount: mount)

        controller.onUpdatedUser = { [weak self] in

            self?.refreshMount()
            _ = self?.navigationController?.popViewController(animated: true)
        }

        navigationController?.pushViewController(controller, animated: true)
    }

    @objc private func handleRemoveMount() {

        guard let mount = sharedNode.mount else {
            print("No valid mount in node for deletion.")
            return
        }

        configureWaitingView(type: .started, message: NSLocalizedString("Removing share...", comment: ""))

        DigiClient.shared.deleteMount(mount) { error in

            guard error == nil else {
                self.configureWaitingView(type: .stopped, message: NSLocalizedString("There was an error while removing the share.", comment: ""))
                return
            }

            self.dismiss(animated: true) {

                if self.sharedNode.mountPath == "/" && self.sharedNode.mount?.type == "export" && self.sharedNode.name == "" {
                    self.onFinish?(true)
                } else {
                    self.onFinish?(false)
                }

            }
        }
    }

    @objc func handleHideWaitingView(_ sender: UIButton) {

        if controllerShouldBeDismissed {
            dismiss(animated: true, completion: nil)
        } else {
            self.configureWaitingView(type: .hidden, message: "")
        }
    }

    @objc private func handleDone() {
        dismiss(animated: true) {
            self.onFinish?(false)
        }
    }

}
