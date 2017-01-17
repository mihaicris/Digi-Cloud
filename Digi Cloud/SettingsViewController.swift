//
//  SettingsViewControllerTableViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 13/01/17.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

    fileprivate let confirmButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.layer.cornerRadius = 5
        b.clipsToBounds = true
        b.setTitleColor(.white, for: .normal)
        b.setTitle(NSLocalizedString("Confirm", comment: "Button Title"), for: .normal)
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        b.addTarget(self, action: #selector(handleLogoutConfirmed), for: .touchUpInside)
        b.contentEdgeInsets = UIEdgeInsets(top: 6, left: 8, bottom: 6, right: 8)
        b.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 0.25, alpha: 1.0)
        return b
    }()

    fileprivate var confirmButtonHorizontalConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Settings", comment: "Window Title")
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var number = 0
        switch section {
        case 0: number = 1
        case 1: number = 1
        default:
            break
        }
        return number
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return NSLocalizedString("USER", comment: "Section title")
        default:
            return NSLocalizedString("NETWORK", comment: "Section title")
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell()
        cell.selectionStyle = .none

        switch indexPath.section {
        case 0:
            cell.textLabel?.text = NSLocalizedString("Logout", comment: "Button Title")
            cell.textLabel?.textColor = .defaultColor
            cell.contentView.addSubview(confirmButton)

            confirmButtonHorizontalConstraint = confirmButton.leftAnchor.constraint(equalTo: cell.contentView.rightAnchor)

            NSLayoutConstraint.activate([
                confirmButton.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                confirmButtonHorizontalConstraint
            ])
        case 1:
            cell.textLabel?.text = NSLocalizedString("Mobile Data", comment: "Button Title")
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

        default:
            break
        }

        return cell
    }

    @objc private func toggleAllowingCellularAccessSetting() {
        AppSettings.allowsCellularAccess = !AppSettings.allowsCellularAccess
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        switch indexPath.section {
        case 0:
            handleLogout(cell)
        default:
            break
        }
    }

    @objc fileprivate func handleLogout(_ cell: UITableViewCell) {
        confirmButtonHorizontalConstraint.isActive = false
        if confirmButton.tag == 0 {
            confirmButton.tag = 1
            confirmButtonHorizontalConstraint = confirmButton.rightAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.rightAnchor)
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

    @objc fileprivate func handleLogoutConfirmed() {
        if let navController = self.navigationController?.presentingViewController as? MainNavigationController {
            AppSettings.loggedAccount = nil
            navController.onLogout?()
        }
    }

    @objc fileprivate func handleAppStoreReview() {
        let urlstring = "itms-apps://itunes.apple.com/app/viewContentsUserReviews?id=1173649518"
        guard let url = URL(string: urlstring) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
