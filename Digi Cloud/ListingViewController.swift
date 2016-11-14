//
//  ListingViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 19/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class ListingViewController: UITableViewController {

    // MARK: - Properties

    var content: [File] = []

    let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        f.locale = Locale.current
        f.dateFormat = "dd.MM.YYY・HH:mm"
        return f
    }()
    let byteFormatter: ByteCountFormatter = {
        let f = ByteCountFormatter()
        f.countStyle = .binary
        f.allowsNonnumericFormatting = false
        return f
    }()

    internal var currentIndex: IndexPath!

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(FileCell.self, forCellReuseIdentifier: "FileCell")
        tableView.register(DirectoryCell.self, forCellReuseIdentifier: "DirectoryCell")
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.rowHeight = AppSettings.tableViewRowHeight
        setupViews()
        getFolderContent()
    }

    fileprivate func setupViews() {
        let sortButton      = UIBarButtonItem(title: NSLocalizedString("Sort", comment: "Button Title"),
                                              style: UIBarButtonItemStyle.plain,
                                              target: self,
                                              action: #selector(handleSortSelect))
        let addFolderButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add,
                                              target: self,
                                              action: #selector(handleAddFolder))
        navigationItem.rightBarButtonItems = [addFolderButton, sortButton]
    }

    func toggleRightBarButtonsActive() {
        guard let buttons = navigationItem.rightBarButtonItems else {
            return
        }
        for button in buttons {
            button.isEnabled = !button.isEnabled
        }
    }

    @objc fileprivate func handleSortSelect() {
        let controller = SortFolderViewController()
        controller.onFinish = { [unowned self] (selection) in
            self.dismiss(animated: true, completion: nil)

            // save the sort method in the App settings
            switch selection {
            case 1:
                AppSettings.sortMethod = .byName
            case 2:
                AppSettings.sortMethod = .byDate
            case 3:
                AppSettings.sortMethod = .bySize
            case 4:
                AppSettings.sortMethod = .byContentType
            default:
                break
            }

            // sort content and reload table
            self.sortContent()
            self.tableView.reloadData()
        }
        controller.modalPresentationStyle = .popover
        guard let button = navigationItem.rightBarButtonItems?[1] else { return }
        controller.popoverPresentationController?.barButtonItem = button
        present(controller, animated: true, completion: nil)
    }

    @objc fileprivate func handleAddFolder() {
        self.dismiss(animated: false, completion: nil) // dismiss any other presented controller
        let controller = CreateFolderViewController()
        controller.onFinish = { [unowned self] (folderName) in
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil) // dismiss AddFolderViewController
                if folderName != nil {
                    self.getFolderContent()
                } else {
                    return // Cancel
                }
            }
        }
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.modalPresentationStyle = .formSheet
        present(navigationController, animated: true, completion: nil)
    }

    func sortContent() {

        AppSettings.sortAscending = true

        switch AppSettings.sortMethod {
        case .byName:        sortByName()
        case .byDate:        sortByDate()
        case .bySize:        sortBySize()
        case .byContentType: sortByContentType()
        }
    }

    fileprivate func sortByName() {
        if AppSettings.showFoldersFirst {
            if AppSettings.sortAscending {
                self.content.sort { return $0.type == $1.type ? ($0.name.lowercased() < $1.name.lowercased()) : ($0.type < $1.type) }
            }
            else {
                self.content.sort { return $0.type == $1.type ? ($0.name.lowercased() > $1.name.lowercased()) : ($0.type < $1.type) }
            }
        } else {
            if AppSettings.sortAscending  {
                self.content.sort { return $0.name.lowercased() < $1.name.lowercased() }
            }
            else {
                self.content.sort { return $0.name.lowercased() > $1.name.lowercased() }
            }
        }
    }

    fileprivate func sortByDate() {
        if AppSettings.showFoldersFirst {
            if AppSettings.sortAscending {
                self.content.sort { return $0.type == $1.type ? ($0.modified > $1.modified) : ($0.type < $1.type) }
            } else {
                self.content.sort { return $0.type == $1.type ? ($0.modified > $1.modified) : ($0.type < $1.type) }
            }
        } else {
            if AppSettings.sortAscending {
                self.content.sort { return $0.modified > $1.modified }
            } else {
                self.content.sort { return $0.modified < $1.modified }
            }
        }
    }

    fileprivate func sortBySize() {
        if AppSettings.sortAscending {
            self.content.sort { return $0.type == $1.type ? ($0.size > $1.size) : ($0.type < $1.type) }
        } else {
            self.content.sort { return $0.type == $1.type ? ($0.size < $1.size) : ($0.type < $1.type) }
        }
    }

    fileprivate func sortByContentType() {
        if AppSettings.sortAscending {
            self.content.sort { return $0.type == $1.type ? ($0.contentType > $1.contentType && $0.name > $1.name) : ($0.type < $1.type) }
        } else {
            self.content.sort { return $0.type == $1.type ? ($0.contentType < $1.contentType && $0.name < $1.name) : ($0.type < $1.type) }
        }
    }

    func getFolderContent() {
        DigiClient.shared.getLocationContent(mount: DigiClient.shared.currentMount, queryPath: DigiClient.shared.currentPath.last!) {
            (content, error) in
            guard error == nil else {
                print("Error: \(error?.localizedDescription)")
                return
            }
            self.content = content ?? []
            self.sortContent()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    func animateActionButton(active: Bool) {
        let actionButton = (tableView.cellForRow(at: currentIndex) as! BaseListCell).actionButton
        let transform = active ? CGAffineTransform.init(rotationAngle: CGFloat(M_PI_2)) : CGAffineTransform.identity
        let color: UIColor = active ? .black : .darkGray
        actionButton.setTitleColor(color, for: .normal)
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIViewAnimationOptions.curveEaseOut, animations: {
            actionButton.transform = transform
        }, completion: nil)
    }

    // MARK: - Table View Data Source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return content.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let data = content[indexPath.row]

        if data.type == "dir" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DirectoryCell", for: indexPath) as! DirectoryCell
            cell.delegate = self

            cell.folderNameLabel.text = data.name

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FileCell", for: indexPath) as! FileCell
            cell.delegate = self

            let modifiedDate = dateFormatter.string(from: Date(timeIntervalSince1970: data.modified/1000))
            cell.fileNameLabel.text = data.name

            let fileSizeString = byteFormatter.string(fromByteCount: data.size) + "・" + modifiedDate
            cell.fileSizeLabel.text = fileSizeString

            return cell
        }
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: false)

        let itemName = content[indexPath.row].name
        let previousPath = DigiClient.shared.currentPath.last!

        if content[indexPath.row].type == "dir" {
            // This is a Folder
            let controller = ListingViewController()
            controller.title = itemName

            let folderPath = previousPath + itemName + "/"
            DigiClient.shared.currentPath.append(folderPath)

            navigationController?.pushViewController(controller, animated: true)

        } else {
            // This is a file
            let controller = ContentViewController()
            controller.title = itemName

            let filePath = previousPath + itemName
            DigiClient.shared.currentPath.append(filePath)

            navigationController?.pushViewController(controller, animated: true)
        }
    }

    deinit {
        DigiClient.shared.currentPath.removeLast()
        #if DEBUG
            print("FilesTableViewController deinit")
        #endif
    }
}

extension ListingViewController: UIPopoverPresentationControllerDelegate {
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        self.animateActionButton(active: false)
        return true
    }
}
