//
//  FolderInfoViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 02/11/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class FolderInfoViewController: UITableViewController {
    var onFinish: (() -> Void)?

    let sizeFormatter: ByteCountFormatter = {
        let f = ByteCountFormatter()
        f.allowsNonnumericFormatting = false
        f.countStyle = .binary
        return f
    }()

    fileprivate var element: File

    fileprivate var rightBarButton: UIBarButtonItem!
    fileprivate var deleteButton: UIButton!

    fileprivate var noElementsLabel = UILabel()
    fileprivate var noElements: (Int?, Int?) = (nil, nil) {
        didSet {
            guard let files = noElements.0,
                let folders = noElements.1 else {
                    return
            }
            DispatchQueue.main.async {
                self.noElementsLabel = {
                    let label = UILabel()
                    let paragraph = NSMutableParagraphStyle()
                    paragraph.lineHeightMultiple = 1.2
                    label.numberOfLines = 2
                    let filesString = files == 1 ? "File" : "Files"
                    let foldersString = folders == 1 ? "Folder" : "Folders"
                    let text = NSLocalizedString("\(files) " + filesString + "\n" + "\(folders) " + foldersString, comment: "Content information")
                    let attributedText = NSAttributedString(string: text, attributes: [NSParagraphStyleAttributeName : paragraph])
                    label.attributedText = attributedText
                    return label
                }()
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 2 )], with: .automatic)
            }
        }
    }

    fileprivate var folderSizeLabel = UILabel()
    fileprivate var folderSize: Int64? {
        didSet {
            DispatchQueue.main.async {
                if let size = self.folderSize {
                    self.folderSizeLabel.text = self.sizeFormatter.string(fromByteCount: size)
                    self.tableView.reloadRows(at: [IndexPath(row: 0, section: 1 )], with: .automatic)
                }
            }
        }
    }

    init(element: File) {
        self.element = element
        super.init(style: .grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        updateFolderInfo()
    }

    fileprivate func updateFolderInfo() {
        DigiClient.shared.getFolderInfo(path: element.name, completionHandler: { (info, error) in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            self.folderSize = info.0
            self.noElements.0 = info.1
            self.noElements.1 = info.2
        })
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:     return NSLocalizedString("Name", comment: "Header title")
        case 1:     return NSLocalizedString("Size", comment: "Header title")
        case 2:     return NSLocalizedString("Elements", comment: "Header title")
        default:    return ""
        }
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0...1: return ""
        case 2:     return NSLocalizedString("Note: Including subfolders", comment: "Information")
        case 3:     return NSLocalizedString("Attention: This action is not reversible!", comment: "Information")
        default:    return ""
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 2:     return 64
        default:    return UITableViewAutomaticDimension
        }
    }

    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        // for last section with the Button Delete
        if section == 3 {
            (view as? UITableViewHeaderFooterView)?.textLabel?.textAlignment = .center
        }
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 0...1:
            return UITableViewAutomaticDimension
        default:
            return UITableViewAutomaticDimension // default
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        switch indexPath.section {
        // Folder name
        case 0:
            let folderIcon: UIImageView = {
                let imageName = element.type == "dir" ? "FolderIcon" : "FileIcon"
                let imageView = UIImageView(image: UIImage(named: imageName))
                imageView.contentMode = .scaleAspectFit
                return imageView
            }()

            let folderName: UILabel = {
                let label = UILabel()
                label.text = element.name
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
            cell.contentView.addSubview(folderSizeLabel)
            cell.contentView.addConstraints(with: "H:|-20-[v0]-20-|", views: folderSizeLabel)
            folderSizeLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
        case 2:
            cell.contentView.addSubview(noElementsLabel)
            cell.contentView.addConstraints(with: "H:|-20-[v0]-|", views: noElementsLabel)
            noElementsLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor, constant: -2).isActive = true
        case 3:
            deleteButton = UIButton(type: UIButtonType.system)
            deleteButton.layer.borderColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5).cgColor
            deleteButton.layer.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.05).cgColor
            deleteButton.layer.cornerRadius = 8
            deleteButton.layer.borderWidth = 1/UIScreen.main.scale * 1.2
            deleteButton.setTitle(NSLocalizedString("     Delete Folder     ", comment: "Title for Button, please keep the leading/trailing spaces"), for: .normal)
            deleteButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            deleteButton.setTitleColor(.red, for: .normal)
            deleteButton.addTarget(self, action: #selector(handleDelete), for: .touchUpInside)

            //constraints
            deleteButton.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(deleteButton)
            deleteButton.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor).isActive = true
            deleteButton.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
        default:
            break
        }
        return cell
    }

    fileprivate func setupViews() {

        tableView.isScrollEnabled = false

        rightBarButton = UIBarButtonItem(title: NSLocalizedString("Done", comment: "Button title"),
                                         style: .plain,
                                         target: self, action: #selector(handleDone))
        self.navigationItem.setRightBarButton(rightBarButton, animated: false)

        self.title = NSLocalizedString("Folder information", comment: "Title")
    }

    @objc fileprivate func handleDone() {
        onFinish?()
    }

    @objc fileprivate func handleDelete() {
        print("Delete")
        deleteButton.isEnabled = false
    }
    
    #if DEBUG
    deinit {
        print("FolderInfoViewController deinit")
    }
    #endif
}
