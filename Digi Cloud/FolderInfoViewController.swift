//
//  FolderInfoViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 02/11/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

final class FolderInfoViewController: UITableViewController {

    // MARK: - Properties

    var onFinish: ((_ success: Bool, _ needRefresh: Bool) -> Void)?
    fileprivate var node: Node
    private let sizeFormatter: ByteCountFormatter = {
        let f = ByteCountFormatter()
        f.allowsNonnumericFormatting = false
        f.countStyle = .binary
        return f
    }()
    private var rightBarButton: UIBarButtonItem!
    private var deleteButton: UIButton!
    private var noElementsLabel = UILabel()
    private var directorySizeLabel = UILabel()
    private var directoryInfo = DirectoryInfo() {
        didSet {
            self.noElementsLabel = {
                let label = UILabel()
                let paragraph = NSMutableParagraphStyle()
                paragraph.lineHeightMultiple = 1.3
                label.numberOfLines = 2

                let filesString: String
                if directoryInfo.files == 1 {
                    filesString = NSLocalizedString("1 file\n", comment: "")
                } else {
                    filesString = NSLocalizedString("%d files\n", comment: "")
                }

                let foldersString: String
                if directoryInfo.directories == 1 {
                    foldersString = NSLocalizedString("1 directory", comment: "")
                } else {
                    foldersString = NSLocalizedString("%d directories", comment: "")
                }

                let text1 = String.localizedStringWithFormat(filesString, directoryInfo.files)
                let text2 = String.localizedStringWithFormat(foldersString, directoryInfo.directories)
                let attributedText = NSMutableAttributedString(string: text1 + text2,
                                                               attributes: [NSParagraphStyleAttributeName: paragraph])
                label.attributedText = attributedText

                return label
            }()
            self.directorySizeLabel.text = self.sizeFormatter.string(fromByteCount: directoryInfo.size)
            self.tableView.reloadData()
        }
    }

    // MARK: - Initializers and Deinitializers

    init(node: Node) {
        self.node = node
        super.init(style: .grouped)
    }

    deinit { DEINITLog(self) }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overridden Methods and Properties

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        updateFolderInfo()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:     return NSLocalizedString("Name", comment: "")
        case 1:     return NSLocalizedString("Size", comment: "")
        case 2:     return NSLocalizedString("Directory content", comment: "")
        default:    return ""
        }
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 2:     return NSLocalizedString("Note: Including subfolders", comment: "")
        case 3:     return NSLocalizedString("This action is not reversible.", comment: "")
        default:    return ""
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 2:     return 70
        default:    return UITableViewAutomaticDimension
        }
    }

    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        // for last section with the Button Delete
        if section == 3 {
            (view as? UITableViewHeaderFooterView)?.textLabel?.textAlignment = .center
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        switch indexPath.section {
        // Folder name
        case 0:
            let folderIcon: UIImageView = {
                let imageView = UIImageView(image: UIImage(named: "FolderIcon"))
                imageView.contentMode = .scaleAspectFit
                return imageView
            }()

            let folderName: UILabel = {
                let label = UILabel()
                label.text = node.name
                return label
            }()

            cell.contentView.addSubview(folderIcon)
            cell.contentView.addSubview(folderName)
            cell.contentView.addConstraints(with: "H:|-20-[v0(26)]-12-[v1]-12-|", views: folderIcon, folderName)
            cell.contentView.addConstraints(with: "V:[v0(26)]", views: folderIcon)
            folderIcon.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
            folderName.centerYAnchor.constraint(equalTo: folderIcon.centerYAnchor).isActive = true
        // Size
        case 1:
            cell.contentView.addSubview(directorySizeLabel)
            cell.contentView.addConstraints(with: "H:|-20-[v0]-20-|", views: directorySizeLabel)
            directorySizeLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
        case 2:
            cell.contentView.addSubview(noElementsLabel)
            cell.contentView.addConstraints(with: "H:|-20-[v0]-|", views: noElementsLabel)
            noElementsLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor, constant: -2).isActive = true
        case 3:
            deleteButton = UIButton(type: UIButtonType.system)
            deleteButton.layer.borderColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5).cgColor
            deleteButton.layer.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.05).cgColor
            deleteButton.layer.cornerRadius = 8
            deleteButton.layer.borderWidth = (1 / UIScreen.main.scale) * 1.2
            deleteButton.setTitle(NSLocalizedString("Delete Directory", comment: ""), for: .normal)
            deleteButton.contentEdgeInsets = UIEdgeInsets(top: 7, left: 15, bottom: 7, right: 15)
            deleteButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            deleteButton.setTitleColor(.red, for: .normal)
            deleteButton.addTarget(self, action: #selector(handleDelete), for: .touchUpInside)

            //  constraints
            deleteButton.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(deleteButton)
            NSLayoutConstraint.activate([
                deleteButton.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
                deleteButton.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
            ])
        default:
            break
        }
        return cell
    }

    // MARK: - Helper Functions

    private func setupViews() {
        tableView.isScrollEnabled = false
        rightBarButton = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""),
                                         style: .plain,
                                         target: self,
                                         action: #selector(handleDone))
        self.navigationItem.setRightBarButton(rightBarButton, animated: false)
        self.title = NSLocalizedString("Directory information", comment: "")
    }

    private func updateFolderInfo() {

        DigiClient.shared.getDirectoryInfo(for: self.node, completion: { (info, error) in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            if let info = info {
                self.directoryInfo = info
            } else {
                // TODO: Show information that folder was not correctly calculated.
            }
        })
    }

    @objc private func handleDone() {
        onFinish?(false, false)
    }

    @objc private func handleDelete() {
        let controller = DeleteViewController(node: node)
        controller.delegate = self
        controller.modalPresentationStyle = .popover
        controller.popoverPresentationController?.permittedArrowDirections = .up
        controller.popoverPresentationController?.sourceView = deleteButton
        controller.popoverPresentationController?.sourceRect = deleteButton.bounds
        present(controller, animated: true, completion: nil)
    }
}

extension FolderInfoViewController: DeleteViewControllerDelegate {
    func onConfirmDeletion() {

        let completion = {

            DigiClient.shared.delete(node: self.node) { (statusCode, error) in

                // TODO: Stop spinner
                guard error == nil else {
                    // TODO: Show message for error
                    print(error!.localizedDescription)
                    return
                }
                if let code = statusCode {
                    switch code {
                    case 200:
                        // Delete successfully completed
                        self.onFinish?(true, true)
                    case 400:
                        // TODO: Alert Bad Request
                        self.onFinish?(false, true)
                    case 404:
                        // File not found, folder will be refreshed
                        self.onFinish?(false, true)
                    default :
                        // TODO: Alert Status Code server
                        self.onFinish?(false, false)
                        return
                    }
                }
            }
        }

        // Dismiss DeleteAlertViewController
        dismiss(animated: true, completion: completion)
    }
}
