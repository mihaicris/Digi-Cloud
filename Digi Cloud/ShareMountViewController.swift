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

    private let node: Node

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
        t.alwaysBounceVertical = false
        t.delegate = self
        t.dataSource = self
        t.tag = 5
        return t
    }()

    private lazy var tableViewForMembers: UITableView = {
        let t = UITableView(frame: CGRect.zero, style: .grouped)
        t.translatesAutoresizingMaskIntoConstraints = false
        t.alwaysBounceVertical = true
        t.delegate = self
        t.dataSource = self
        t.bounces = false
        t.tag = 10
        t.register(MountUserCell.self, forCellReuseIdentifier: String(describing: MountUserCell.self))
        return t
    }()

    let membersLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = NSLocalizedString("MEMBERS", comment: "")
        l.font = UIFont(name: "Helvetica", size: 13)
        l.textColor = UIColor(red: 0.43, green: 0.43, blue: 0.45, alpha: 1.0)
        return l
    }()

    private var errorMessageVerticalConstraint: NSLayoutConstraint?

    private lazy var waitingView: UIView = {

        let v = UIView()

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
        navigationController?.isToolbarHidden = false
        configureWaitingView(type: .started, message: NSLocalizedString("Preparing Share", comment: ""))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        users = node.share?.users ?? []
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
            if users.count > 0 {
                membersLabel.isHidden = false
            } else {
                membersLabel.isHidden = true
            }
            return users.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if tableView.tag == 5 {

            let cell = UITableViewCell()
            cell.isUserInteractionEnabled = false
            cell.selectionStyle = .none

            let mountNameLabel: UILabelWithPadding = {
                let l = UILabelWithPadding(paddingTop: 1, paddingLeft: 5, paddingBottom: 2, paddingRight: 5)
                l.font = UIFont(name: "HelveticaNeue", size: 14)
                l.adjustsFontSizeToFitWidth = true
                l.textColor = .white
                l.backgroundColor = UIColor.red.withAlphaComponent(0.5)
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
                l.font = UIFont(name: "HelveticaNeue", size: 14)
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

            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MountUserCell.self), for: indexPath) as? MountUserCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            cell.user = users[indexPath.row]

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
            tableViewForLocation.heightAnchor.constraint(equalToConstant: 120),
            tableViewForLocation.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableViewForLocation.rightAnchor.constraint(equalTo: view.rightAnchor),

            membersLabel.bottomAnchor.constraint(equalTo: tableViewForLocation.bottomAnchor, constant: -10),
            membersLabel.leadingAnchor.constraint(equalTo: tableViewForLocation.layoutMarginsGuide.leadingAnchor),

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

        let addMemberButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAddMember))

        let flexibleButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)

        let removeShareButton: UIBarButtonItem = {
            let v = UIButton(type: UIButtonType.system)
            v.setTitle(NSLocalizedString("Remove Share", comment: ""), for: .normal)
            v.addTarget(self, action: #selector(handleRemoveShare), for: .touchUpInside)
            v.setTitleColor(UIColor(white: 0.8, alpha: 1), for: .disabled)
            v.setTitleColor(.red, for: .normal)
            v.titleLabel?.font = UIFont.systemFont(ofSize: 18)
            v.sizeToFit()
            let b = UIBarButtonItem(customView: v)
            return b
        }()

        var toolBarItems = [flexibleButton, addMemberButton]

        if node.share != nil {
            toolBarItems.insert(removeShareButton, at: 0)
        }

        setToolbarItems(toolBarItems, animated: false)
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

    @objc private func handleRemoveShare() {

        guard let mount = node.share else {
            print("No valid mount in node for deletion.")
            return
        }

        // TODO: Start activity indicator

        DigiClient.shared.deleteMount(mount) { error in

            // TODO: Stop activity indicator

            guard error == nil else {
                // TODO: Show Error to User

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

    @objc func handleAddMember() {

    }

}
