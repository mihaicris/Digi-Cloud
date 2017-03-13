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

    var onFinish: (() -> Void)?

    private let location: Location

    private var node: Node

    private var mappingProfileImages: [String: UIImage] = [:]

    private var users: [User] = []

    private var hasAppearedOnce = false

    enum TableViewType: Int {
        case location = 0
        case members
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
        t.tag = TableViewType.members.rawValue
        t.register(MountUserCell.self, forCellReuseIdentifier: String(describing: MountUserCell.self))
        return t
    }()

    let membersLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = NSLocalizedString("MEMBERS", comment: "")
        l.font = UIFont(name: "HelveticaNeue", size: 13)
        l.textColor = UIColor(red: 0.43, green: 0.43, blue: 0.45, alpha: 1.0)
        return l
    }()

    private lazy var addMemberButton: UIButton = {
        let b = UIButton(type: UIButtonType.contactAdd)
        b.addTarget(self, action: #selector(showAddMemberView), for: .touchUpInside)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
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

    init(location: Location, node: Node, onFinish: @escaping () -> Void) {
        self.location = location
        self.node = node
        self.onFinish = onFinish
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit { DEINITLog(self) }

    // MARK: - Overridden Methods and Properties

    override func viewDidLoad() {
        setupViews()
        setupNavigationItems()
        setupToolBarItems()

        if node.share?.isShared == true {
            configureWaitingView(type: .started, message: NSLocalizedString("Loading members...", comment: ""))
        } else {
            configureWaitingView(type: .started, message: NSLocalizedString("Preparing Share...", comment: ""))
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if hasAppearedOnce { return }

        hasAppearedOnce = true

        if let mount = node.share, mount.isShared == true {
            getUserProfileImages(for: mount.users)

        } else {
            createMount()
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        var headerTitle: String?

        guard let type = TableViewType(rawValue: tableView.tag) else {
            return headerTitle
        }

        switch type {
        case .location:
            headerTitle = NSLocalizedString("LOCATION", comment: "")
        case .members:
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
        case .members:
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
        case .members:
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
                l.font = UIFont(name: "HelveticaNeue", size: 12)
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
                l.text = location.path.hasSuffix("/") ? String(location.path.characters.dropLast()) : location.path
                l.numberOfLines = 2
                l.font = UIFont(name: "HelveticaNeue", size: 12)
                l.lineBreakMode = .byTruncatingMiddle
                return l
            }()

            cell.contentView.addSubview(mountNameLabel)
            cell.contentView.addSubview(locationPathLabel)

            NSLayoutConstraint.activate([
                locationPathLabel.leadingAnchor.constraint(equalTo: mountNameLabel.trailingAnchor, constant: 2),
                locationPathLabel.trailingAnchor.constraint(lessThanOrEqualTo : cell.contentView.layoutMarginsGuide.trailingAnchor),
                locationPathLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),

                mountNameLabel.leadingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.leadingAnchor),
                mountNameLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)])

            return cell

        case .members:

            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MountUserCell.self), for: indexPath) as? MountUserCell else {
                return UITableViewCell()
            }

            let user = users[indexPath.row]
            cell.selectionStyle = .none

            if let owner = node.share?.owner {
                if owner == user {
                    cell.isOwner = true
                    cell.isUserInteractionEnabled = false
                } else {
                    cell.accessoryType = .disclosureIndicator
                }
            }

            cell.user = user

            if let image = mappingProfileImages[users[indexPath.row].id] {
                cell.profileImageView.image = image
            } else {
                cell.profileImageView.image = #imageLiteral(resourceName: "AccountIcon")
            }

            return cell

        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard let mount = node.share else {
            print("No valid mount in node for editing.")
            return
        }

        let user = users[indexPath.row]

        let controller = AddMountUserViewController(mount: mount, user: user)

        controller.onUpdatedUser = { [weak self] user in
            self?.getUserProfileImages(for: [user], needsDismiss: true)
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
            iv.contentMode = .scaleAspectFit
            return iv
        }()

        view.addSubview(headerView)
        view.addSubview(tableViewForLocation)
        view.addSubview(tableViewForUsers)
        view.addSubview(membersLabel)
        view.addSubview(addMemberButton)
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

            membersLabel.bottomAnchor.constraint(equalTo: tableViewForLocation.bottomAnchor, constant: -10),
            membersLabel.leadingAnchor.constraint(equalTo: tableViewForLocation.layoutMarginsGuide.leadingAnchor),

            addMemberButton.centerYAnchor.constraint(equalTo: membersLabel.centerYAnchor),
            addMemberButton.trailingAnchor.constraint(equalTo: tableViewForLocation.layoutMarginsGuide.trailingAnchor),

            tableViewForUsers.topAnchor.constraint(equalTo: tableViewForLocation.bottomAnchor),
            tableViewForUsers.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableViewForUsers.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableViewForUsers.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }

    private func setupNavigationItems() {

        title = NSLocalizedString("Members", comment: "")
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Back", comment: ""), style: .plain, target: nil, action: nil)

        let doneButton = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: .plain, target: self, action: #selector(handleDone))
        navigationItem.setRightBarButton(doneButton, animated: false)
    }

    private func setupToolBarItems() {

        let flexibleButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)

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

        setToolbarItems([flexibleButton, removeShareButton], animated: false)
    }

    private func configureWaitingView(type: WaitingType, message: String) {

        switch type {
        case .hidden:
            waitingView.isHidden = true
            navigationController?.setToolbarHidden(false, animated: false)
        case .started, .stopped:
            waitingView.isHidden = false
            navigationController?.setToolbarHidden(true, animated: false)
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

        DigiClient.shared.createSubmount(at: location, withName: node.name) { mount, error in

            guard error == nil else {

                var errorMessage = NSLocalizedString("There was an error at mount creation.", comment: "")

                switch error! {

                case NetworkingError.wrongStatus(let message):
                    errorMessage = message
                default:
                    break
                }

                self.configureWaitingView(type: .stopped, message: errorMessage)

                return
            }

            if let mount = mount {
                self.saveMount(mount)
                self.getUserProfileImages(for: mount.users)
            }
        }
    }

    private func getUserProfileImages(for someUsers: [User], needsDismiss: Bool = false) {

        let dispatchGroup = DispatchGroup()

        for user in someUsers {

            // if profile image already available, skip network request
            if mappingProfileImages[user.id] != nil {
                continue
            }

            dispatchGroup.enter()

            DigiClient.shared.getUserProfileImage(for: user, completion: { (image, error) in

                dispatchGroup.leave()

                guard error == nil else {
                    return
                }

                if let image = image {
                    self.mappingProfileImages[user.id] = image
                }
            })
        }

        dispatchGroup.notify(queue: .main) {
            self.saveUsers(someUsers)
            self.tableViewForUsers.reloadData()
            self.configureWaitingView(type: .hidden, message: "")

            if needsDismiss {
                _ = self.navigationController?.popViewController(animated: true)
            } else {
                self.navigationController?.isToolbarHidden = false
            }
        }
    }

    private func saveMount(_ mount: Mount) {
        node.share = mount

        if let viewControllers = navigationController?.viewControllers {
            let count = viewControllers.count
            if count > 0 {
                (viewControllers[count-2] as? ShareViewController)?.node.share = mount
            }
        }
    }

    private func removeUser(at indexPath: IndexPath) {

        guard let mount = node.share else {
            print("No valid mount for user addition.")
            return
        }

        let user = users[indexPath.row]

        DigiClient.shared.updateMount(mount: mount, operation: .remove, user: user) { _, error in

            guard error == nil else {
                self.configureWaitingView(type: .stopped, message: "There was an error while removing the member.")
                return
            }

            self.users.remove(at: indexPath.row)
            self.updateUsersInMainShareController()

            // Remove from tableView
            self.tableViewForUsers.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    private func saveUsers(_ someUsers: [User]) {

        // if the user already exists in the users array replace it (maybe it has new permissions)
        // otherwise add it to the array
        for user in someUsers {

            if let index = users.index(of: user) {
                users[index] = user
            } else {
                users.append(user)
            }
        }

        // Update the node mount users
        node.share?.users = self.users

        self.updateUsersInMainShareController()
    }

    private func updateUsersInMainShareController() {

        // Update mount in main share ontroller on navigation stack

        if let viewControllers = navigationController?.viewControllers,
            let shareViewController = viewControllers.first as? ShareViewController {
                shareViewController.node.share?.users = self.users
            }
    }

    @objc private func showAddMemberView() {

        guard let mount = node.share else {
            print("No valid mount for user addition.")
            return
        }

        let controller = AddMountUserViewController(mount: mount)

        controller.onUpdatedUser = { [weak self] user in
            self?.getUserProfileImages(for: [user], needsDismiss: true)
        }

        navigationController?.pushViewController(controller, animated: true)
    }

    @objc private func handleRemoveMount() {

        guard let mount = node.share else {
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
                self.onFinish?()
            }
        }
    }

    @objc func handleHideWaitingView(_ sender: UIButton) {
        self.configureWaitingView(type: .hidden, message: "")
    }

    @objc private func handleDone() {
        dismiss(animated: true) {
            self.onFinish?()
        }
    }

}
