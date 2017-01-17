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
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var number = 0

        switch section {

        case 0: number = 1

        default:
            break
        }

        return number
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString("USER", comment: "Section title")
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell()
        cell.selectionStyle = .none

        switch indexPath.section {
        case 0:
            cell.textLabel?.text = NSLocalizedString("Logout", comment: "Button Title")
            cell.textLabel?.textColor = .defaultColor
            cell.contentView.addSubview(confirmButton)

            confirmButtonHorizontalConstraint = confirmButton.leadingAnchor.constraint(equalTo: cell.contentView.trailingAnchor)

            NSLayoutConstraint.activate([
                confirmButton.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                confirmButtonHorizontalConstraint
            ])

        default:
            break
        }

        return cell
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
            confirmButtonHorizontalConstraint = confirmButton.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -10)
        } else {
            confirmButton.tag = 0
            confirmButtonHorizontalConstraint = confirmButton.leadingAnchor.constraint(equalTo: cell.contentView.trailingAnchor)
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
