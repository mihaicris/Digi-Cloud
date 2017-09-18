//
//  SettingsViewControllerTableViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 13/01/17.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import UIKit

final class SettingsViewController: UITableViewController {

    enum SettingType {
        case user
        case security
        case data
    }

    // MARK: - Properties

    private var isExecuting = false

    private var user: User

    private var profileImage: UIImage! = #imageLiteral(resourceName: "default_profile_image")

    private var settings: [SettingType] = [.user, .security, .data]

    lazy var closeButton: UIBarButtonItem = {
        let b = UIBarButtonItem(title: NSLocalizedString("Close", comment: ""), style: .plain, target: self, action: #selector(handleDismiss))
        return b
    }()

    private let confirmButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitleColor(.white, for: .normal)
        b.setTitle(NSLocalizedString("Confirm", comment: ""), for: .normal)
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        b.addTarget(self, action: #selector(handleLogoutConfirmed), for: .touchUpInside)
        b.contentEdgeInsets = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
        b.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 0.25, alpha: 1.0)
        return b
    }()

    private let byteFormatter: ByteCountFormatter = {
        let f = ByteCountFormatter()
        f.countStyle = .binary
        f.allowsNonnumericFormatting = false
        return f
    }()

    private var confirmButtonHorizontalConstraint: NSLayoutConstraint!

    // MARK: - Initializers and Deinitializers

    init(user: User) {
        self.user = user
        super.init(style: .grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit { DEINITLog(self) }

    // MARK: - Overridden Methods and Properties

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Settings", comment: "")
        preferredContentSize = CGSize(width: 350, height: 490)
        setupViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUserData()
        tableView.reloadData()
    }

    private func setupViews() {

        let tableFooterView: UIView = {
            let v = UIView()
            v.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 70)

            let versionLabel: UILabel = {
                let l = UILabel()
                l.numberOfLines = 0
                l.translatesAutoresizingMaskIntoConstraints = false
                l.textAlignment = .center
                l.text = Bundle.main.prettyVersionString
                l.textColor = UIColor.gray
                l.font = UIFont.HelveticaNeue(size: 12)
                return l
            }()

            v.addSubview(versionLabel)

            NSLayoutConstraint.activate([
                versionLabel.topAnchor.constraint(equalTo: v.topAnchor, constant: 10),
                versionLabel.centerXAnchor.constraint(equalTo: v.centerXAnchor)
            ])

            return v
        }()

        tableView.tableFooterView = tableFooterView
        self.navigationItem.leftBarButtonItem = self.closeButton
    }

    private func fetchUserData() {

        if let user = AppSettings.userLogged {

            self.user = user

            let cache = Cache()
            let key = self.user.id + ".png"

            if let data = cache.load(type: .profile, key: key) {
                self.profileImage = UIImage(data: data, scale: UIScreen.main.scale)
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return settings.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch settings[section] {
        case .user:
            return 2

        case .security:
            return 1

        case .data:

            return FileManager.sizeOfFilesCacheFolder() == 0 ? 1 : 2

        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        switch settings[section] {
        case .user:
            return NSLocalizedString("User", comment: "")

        case .security:
            return NSLocalizedString("Security", comment: "")

        case .data:
            return NSLocalizedString("Data", comment: "")
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch settings[indexPath.section] {
        case .user:
            return indexPath.row == 0 ? 80 : UITableViewAutomaticDimension

        default:
            return UITableViewAutomaticDimension
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.selectionStyle = .none

        switch settings[indexPath.section] {
        case .user:

            if indexPath.row == 0 {

                cell.accessoryType = .disclosureIndicator

                let profileImageView: UIImageView = {
                    let iv = UIImageView()
                    iv.translatesAutoresizingMaskIntoConstraints = false
                    iv.layer.cornerRadius = 10
                    iv.layer.masksToBounds = true
                    iv.contentMode = .scaleAspectFill
                    iv.image = self.profileImage
                    return iv
                }()

                let usernameLabel: UILabel = {
                    let l = UILabel()
                    l.translatesAutoresizingMaskIntoConstraints = false
                    l.text = "\(user.firstName) \(user.lastName)"
                    l.font = UIFont.HelveticaNeueMedium(size: 16)
                    return l
                }()

                let userloginLabel: UILabel = {
                    let l = UILabel()
                    l.translatesAutoresizingMaskIntoConstraints = false
                    l.text = self.user.email
                    l.textColor = UIColor.gray
                    l.font = UIFont.HelveticaNeue(size: 14)
                    return l
                }()

                cell.contentView.addSubview(profileImageView)
                cell.contentView.addSubview(usernameLabel)
                cell.contentView.addSubview(userloginLabel)

                NSLayoutConstraint.activate([
                    profileImageView.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                    profileImageView.leftAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.leftAnchor),
                    profileImageView.heightAnchor.constraint(equalToConstant: 60),
                    profileImageView.widthAnchor.constraint(equalToConstant: 60),

                    userloginLabel.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor),
                    userloginLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8),

                    usernameLabel.bottomAnchor.constraint(equalTo: userloginLabel.topAnchor),
                    usernameLabel.leftAnchor.constraint(equalTo: userloginLabel.leftAnchor)])

            } else {
                cell.textLabel?.text = NSLocalizedString("Switch Account", comment: "")
                cell.textLabel?.textColor = .defaultColor
                cell.contentView.addSubview(confirmButton)

                confirmButtonHorizontalConstraint = confirmButton.leftAnchor.constraint(equalTo: cell.contentView.rightAnchor)

                NSLayoutConstraint.activate([
                    confirmButton.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                    confirmButton.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
                    confirmButtonHorizontalConstraint])
            }

        case .security:

            cell.textLabel?.text = NSLocalizedString("Links Password", comment: "")
            cell.accessoryType = .disclosureIndicator

        case .data:

            switch indexPath.row {

            case 0:
                cell.textLabel?.text = NSLocalizedString("Mobile Data", comment: "")
                let mobileDataUISwitch: UISwitch = {
                    let s = UISwitch()
                    s.isOn = AppSettings.allowsCellularAccess
                    s.translatesAutoresizingMaskIntoConstraints = false
                    s.addTarget(self, action: #selector(toggleAllowingCellularAccessSetting), for: .valueChanged)
                    return s
                }()

                cell.contentView.addSubview(mobileDataUISwitch)
                NSLayoutConstraint.activate([
                    mobileDataUISwitch.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                    mobileDataUISwitch.rightAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.rightAnchor)
                    ])
            case 1:
                // Clean cache
                cell.textLabel?.text = NSLocalizedString("Clear Cache", comment: "")
                cell.textLabel?.textColor = .defaultColor

                cell.detailTextLabel?.font = UIFont.HelveticaNeue(size: 14)

                let str = NSLocalizedString("Total:", comment: "")

                var sizeString = NSLocalizedString("Error", comment: "")

                let size = FileManager.sizeOfFilesCacheFolder()
                sizeString = byteFormatter.string(fromByteCount: Int64(size))

                cell.detailTextLabel?.text = "\(str) \(sizeString)"

            default:
                break
            }
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard let cell = tableView.cellForRow(at: indexPath) else { return }

        switch settings[indexPath.section] {

        case .user:
            if indexPath.row == 0 {
                let controller = UserSettingsViewController(user: user)
                navigationController?.pushViewController(controller, animated: true)
            } else {
                handleLogout(cell)
            }

        case .security:
            let controller = SecuritySettingsViewController(style: .grouped)
            navigationController?.pushViewController(controller, animated: true)

        case .data:
            if indexPath.row == 1 {
                handleClearCache()
            }
        }
    }

    // MARK: - Helper Functions

    @objc private func toggleAllowingCellularAccessSetting() {
        AppSettings.allowsCellularAccess = !AppSettings.allowsCellularAccess
        DigiClient.shared.renewSession()
    }

    @objc private func handleLogout(_ cell: UITableViewCell) {
        confirmButtonHorizontalConstraint.isActive = false
        if confirmButton.tag == 0 {
            confirmButton.tag = 1
            confirmButtonHorizontalConstraint = confirmButton.rightAnchor.constraint(equalTo: cell.contentView.rightAnchor)
        } else {
            confirmButton.tag = 0
            confirmButtonHorizontalConstraint = confirmButton.leftAnchor.constraint(equalTo: cell.contentView.rightAnchor)
        }
        confirmButtonHorizontalConstraint.isActive = true

        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 1,
                       options: .curveEaseOut,
                       animations: { cell.layoutIfNeeded() },
                       completion: nil)
    }

    @objc private func handleLogoutConfirmed() {

        guard !isExecuting else { return }
        isExecuting = true

        if let navController = self.navigationController?.presentingViewController as? MainNavigationController {
            AppSettings.loggedUserID = nil

            dismiss(animated: true) {

                if let controller = navController.visibleViewController as? LocationsViewController {
                    controller.activityIndicator.startAnimating()
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    navController.viewControllers = []
                    navController.onLogout?()
                }
            }
        }
    }

    @objc private func handleAppStoreReview() {

        if #available(iOS 10.0, *) {
            let urlstring = "itms-apps://itunes.apple.com/app/viewContentsUserReviews?id=1173649518"
            guard let url = URL(string: urlstring) else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            let urlstring = "https://itunes.apple.com/app/id1173649518"
            guard let url = URL(string: urlstring) else { return }
            UIApplication.shared.openURL(url)
        }
    }

    @objc private func handleDismiss() {
        self.dismiss(animated: true, completion: nil)
    }

    private func handleClearCache() {
        FileManager.emptyFilesCache()
        tableView.reloadSections(IndexSet(integer: 2), with: .fade)
    }
}
