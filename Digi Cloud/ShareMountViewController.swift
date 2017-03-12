//
//  ShareMountViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 02/03/2017.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import UIKit

final class ShareMountViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    // MARK: - Properties

    var onFinish: (() -> Void)?

    private let location: Location

    private var node: Node

    private var mappingProfileImages: [String: UIImage] = [:]

    private var users: [User] = [] {

        didSet {

            let dispatchGroup = DispatchGroup()

            for user in users {

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
                self.tableViewForMembers.reloadData()
                self.configureWaitingView(type: .hidden, message: "")
            }
        }
    }

    private lazy var tableViewForLocation: UITableView = {
        let t = UITableView(frame: CGRect.zero, style: .grouped)
        t.translatesAutoresizingMaskIntoConstraints = false
        t.isUserInteractionEnabled = false
        t.delegate = self
        t.dataSource = self
        t.tag = 5
        return t
    }()

    private lazy var tableViewForMembers: UITableView = {
        let t = UITableView(frame: CGRect.zero, style: .plain)
        t.translatesAutoresizingMaskIntoConstraints = false
        t.alwaysBounceVertical = true
        t.delegate = self
        t.dataSource = self
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

        v.isHidden = true

        v.backgroundColor = .white
        v.translatesAutoresizingMaskIntoConstraints = false

        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        spinner.tag = 55
        spinner.startAnimating()

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .gray
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        label.tag = 99
        label.numberOfLines = 0

        v.addSubview(spinner)
        v.addSubview(label)

        self.errorMessageVerticalConstraint = label.centerYAnchor.constraint(equalTo: v.centerYAnchor, constant: 40)

        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: v.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: v.centerYAnchor),
            label.centerXAnchor.constraint(equalTo: v.centerXAnchor),
            label.widthAnchor.constraint(equalTo: v.widthAnchor, multiplier: 0.8),
            self.errorMessageVerticalConstraint! ])

        return v
    }()

    private let addViewTopConstraint: NSLayoutConstraint?

    private let addView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .lightGray
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
        navigationController?.isToolbarHidden = false
        setupViews()
        setupNavigationItems()

        if node.share?.isShared == true {
            configureWaitingView(type: .started, message: NSLocalizedString("Loading members...", comment: ""))
        } else {
            configureWaitingView(type: .started, message: NSLocalizedString("Preparing Share...", comment: ""))
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setupToolBarItems()

        if node.share?.isShared == true {
            users = node.share?.users ?? []
        } else {
            makeSubmount()
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        var headerTitle: String?

        if tableView.tag == 5 {
            headerTitle = NSLocalizedString("LOCATION", comment: "")
        }

        return headerTitle

    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView.tag == 5 {
            return 35
        } else {
            return 0.01
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 5 {
            return 1
        } else {
            return users.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // LOCATION Table
        if tableView.tag == 5 {

            let cell = UITableViewCell()
            cell.isUserInteractionEnabled = false
            cell.selectionStyle = .none

            let mountNameLabel: UILabelWithPadding = {
                let l = UILabelWithPadding(paddingTop: 1, paddingLeft: 5, paddingBottom: 2, paddingRight: 5)
                l.font = UIFont(name: "HelveticaNeue", size: 12)
                l.adjustsFontSizeToFitWidth = true
                l.textColor = .darkGray
                l.backgroundColor = UIColor.black.withAlphaComponent(0.1)
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

        } else {

            // MEMBERS TABLE
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MountUserCell.self), for: indexPath) as? MountUserCell else {
                return UITableViewCell()
            }

            let user = users[indexPath.row]
            cell.selectionStyle = .none

            if let owner = node.share?.owner {
                if owner == user {
                    cell.isOwner = true
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
        view.addSubview(tableViewForMembers)
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

            tableViewForMembers.topAnchor.constraint(equalTo: tableViewForLocation.bottomAnchor),
            tableViewForMembers.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableViewForMembers.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableViewForMembers.rightAnchor.constraint(equalTo: view.rightAnchor)
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
            if let v = waitingView.viewWithTag(55) as? UIActivityIndicatorView {
                if type == .started {
                    v.startAnimating()
                    errorMessageVerticalConstraint?.constant = 40
                } else {
                    v.stopAnimating()
                    errorMessageVerticalConstraint?.constant = 0
                }
            }

            if let v = waitingView.viewWithTag(99) as? UILabel {
                v.text = message
            }
        }
    }

    private func makeSubmount() {

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
            }
        }
    }

    private func saveMount(_ mount: Mount) {
        node.share = mount
        users = node.share?.users ?? []

        if let viewControllers = navigationController?.viewControllers {
            let count = viewControllers.count
            if count > 0 {
                (viewControllers[count-2] as? ShareViewController)?.node.share = mount
            }
        }
    }

    private func updateUser(_ user: User) {

        if let index = users.index(of: user) {
            users[index] = user
        } else {
            users.append(user)
        }

        users.append(User(id: "1", name: "John Smith", email: "john.smith@apple.com", permissions: Permissions.init(mount: true)))

        node.share?.users = users

        if let viewControllers = navigationController?.viewControllers {
            let count = viewControllers.count
            if count > 0 {

                (viewControllers[count-2] as? ShareViewController)?.node.share?.users.append(user)
            }
        }
    }

    private func showAddMemberView() {

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

    @objc private func handleDone() {
        dismiss(animated: true) {
            self.onFinish?()
        }
    }

    @objc private func handleAddUser() {

        guard let mount = node.share else {
            print("No valid mount in node for edit.")
            return
        }

        configureWaitingView(type: .started, message: "Adding user...")

        let permissions = Permissions()
        let user = User(id: "", name: "", email: "mcristesc@yahoo.com", permissions: permissions)

        DigiClient.shared.updateMount(mount: mount, operation: .add, user: user) { user, error in

            guard error == nil else {

                self.configureWaitingView(type: .stopped, message: "Error on adding user.")
                return
            }

            if let user = user {
                self.configureWaitingView(type: .hidden, message: "")
                self.updateUser(user)
            }
        }
    }
}
