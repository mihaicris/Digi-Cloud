//
//  SecuritySettingsTableViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 19/03/2017.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import UIKit

class SecuritySettingsViewController: UITableViewController {

    enum SwitchType: Int {
        case download
        case reiceive
    }

    let downloadLinkSwitch: UISwitch = {
        let sw = UISwitch()
        sw.translatesAutoresizingMaskIntoConstraints = false
        sw.tag = SwitchType.download.rawValue
        sw.addTarget(self, action: #selector(handleToogleSwitch(_:)), for: .valueChanged)
        return sw
    }()

    let receiveLinkSwitch: UISwitch = {
        let sw = UISwitch()
        sw.translatesAutoresizingMaskIntoConstraints = false
        sw.tag = SwitchType.reiceive.rawValue
        sw.addTarget(self, action: #selector(handleToogleSwitch(_:)), for: .valueChanged)
        return sw
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Security", comment: "")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString("Auto Password Links", comment: "")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none

            if indexPath.row == 0 {
                cell.contentView.addSubview(downloadLinkSwitch)

                downloadLinkSwitch.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
                downloadLinkSwitch.rightAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.rightAnchor).isActive = true

                cell.textLabel?.text = NSLocalizedString("Download Link", comment: "")
                downloadLinkSwitch.isOn = AppSettings.shouldPasswordDownloadLink
            } else {

                cell.contentView.addSubview(receiveLinkSwitch)

                receiveLinkSwitch.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
                receiveLinkSwitch.rightAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.rightAnchor).isActive = true

                cell.textLabel?.text = NSLocalizedString("Receive Link", comment: "")
                receiveLinkSwitch.isOn = AppSettings.shouldPasswordReceiveLink
            }

        return cell
    }

    @objc private func handleToogleSwitch(_ sender: UISwitch) {

        func toogle(sw: SwitchType) {

            switch sw {
            case .download:
                downloadLinkSwitch.isOn = !downloadLinkSwitch.isOn
            case .reiceive:
                receiveLinkSwitch.isOn = !receiveLinkSwitch.isOn

            }
        }

        guard let switchType = SwitchType(rawValue: sender.tag) else {
            return
        }

        toogle(sw: switchType)

        DigiClient.shared.setSecuritySettings(shouldPasswordDownloadLink: downloadLinkSwitch.isOn,
                                              shouldPasswordReceiveLink: receiveLinkSwitch.isOn) { error in

            guard error == nil else {
                toogle(sw: switchType)
                return
            }

            AppSettings.shouldPasswordDownloadLink = self.downloadLinkSwitch.isOn
            AppSettings.shouldPasswordReceiveLink = self.receiveLinkSwitch.isOn
        }
    }
}
