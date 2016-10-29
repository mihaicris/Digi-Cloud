//
//  FilesTableViewController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 19/09/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class FilesTableViewController: UITableViewController {

    enum Sorting {
        case ascending
        case descending
    }
    // MARK: - Properties

    var content: [File] = []

    fileprivate var currentIndex: IndexPath!

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(FileCell.self, forCellReuseIdentifier: "FileCell")
        tableView.register(DirectoryCell.self, forCellReuseIdentifier: "DirectoryCell")
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.rowHeight = 50

        getFolderContent()
    }

    // TODO: Implement sorting filters in the interface

    fileprivate func sortContent() {

        // check settings and choose appropriate sorting function name/size/date
        sortByName(directoryFirst: true, direction: .ascending)
    }

    fileprivate func sortByName(directoryFirst: Bool, direction: Sorting) {
        self.content.sort {
            if directoryFirst {
                if direction == .ascending {
                    // Order items by name (ascending), directories are shown first
                    return $0.type == $1.type ? ($0.name.lowercased() < $1.name.lowercased()) : ($0.type < $1.type)
                } else {
                    return $0.type == $1.type ? ($0.name.lowercased() > $1.name.lowercased()) : ($0.type < $1.type)
                }
            } else {
                //  Order items by name (ascending)
                if direction == .ascending {
                    return $0.name.lowercased() < $1.name.lowercased()
                } else {
                    return $0.name.lowercased() > $1.name.lowercased()
                }
            }
        }
    }

    fileprivate func sortByDate(directoryFirst: Bool, direction: Sorting) {

        // TODO: Implement sort by date
        /* Order items by Date (descending), directories are shown first */
        // return $0.type == $1.type && $0.type != "dir" ? ($0.modified > $1.modified) : ($0.type < $1.type)
    }

    fileprivate func sortBySize(directoryFirst: Bool, direction: Sorting) {
        // TODO: Implement sort by size
    }

    fileprivate func getFolderContent() {
        DigiClient.shared.getLocationContent(mount: DigiClient.shared.currentMount, queryPath: DigiClient.shared.currentPath.last!) {
            (content, error) in
            if error != nil {
                print("Error: \(error)")
            }
            self.content = content ?? []
            self.sortContent()
            DispatchQueue.main.async { self.tableView.reloadData() }
        }
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

            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            formatter.locale = Locale.current
            formatter.dateFormat = "dd.MM.YYY・HH:mm"

            let modifiedDate = formatter.string(from: Date(timeIntervalSince1970: data.modified/1000))
            cell.fileNameLabel.text = data.name

            let fileSizeString = ByteCountFormatter.string(fromByteCount: Int64(data.size), countStyle: ByteCountFormatter.CountStyle.file) + "・" + modifiedDate
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
            let controller = FilesTableViewController()
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

extension FilesTableViewController: BaseListCellDelegate {
    func showActionController(for sourceView: UIView) {
        let buttonPosition = sourceView.convert(CGPoint.zero, to: self.tableView)
        guard let indexPath = tableView.indexPathForRow(at: buttonPosition) else { return }

        currentIndex = indexPath

        let controller = ActionsViewController(style: .plain)
        controller.delegate = self

        controller.element = self.content[indexPath.row]
        controller.modalPresentationStyle = .popover

        controller.popoverPresentationController?.sourceView = sourceView
        controller.popoverPresentationController?.sourceRect = sourceView.bounds
        present(controller, animated: true, completion: nil)
    }
}

extension FilesTableViewController: ActionsViewControllerDelegate {
    func didSelectOption(tag: Int) {
        switch tag {
        // rename action
        case 2:

            // TODO: Refactor sort, refresh
            let controller = RenameViewController(element: content[currentIndex.row])
            controller.onSuccess = { [weak self] (newName) in
                if let vc = self {
                    vc.content[vc.currentIndex.row].name = newName
                    vc.sortContent()
                    DispatchQueue.main.async {
                        vc.tableView.reloadData()
                    }
                }
            }
            controller.onRefreshFolder = { [weak self] in
                self?.getFolderContent()
            }
            let navController = UINavigationController(rootViewController: controller)
            navController.modalPresentationStyle = .formSheet
            present(navController, animated: true, completion: nil)

        // delete action
        case 5:
            let element = content[currentIndex.row]
            switch element.type {
            case "file":
                let controller = DeleteFileViewController(element: content[currentIndex.row])
                controller.onSuccess = { [weak self] in
                    if let vc = self {
                        vc.content.remove(at: vc.currentIndex.row)
                        DispatchQueue.main.async {
                            vc.tableView.deleteRows(at: [vc.currentIndex], with: .left)
                        }
                    }
                }
                let view = tableView.cellForRow(at: currentIndex)!.contentView.subviews[0].subviews[0]
                controller.modalPresentationStyle = .popover
                controller.popoverPresentationController?.sourceView = view
                controller.popoverPresentationController?.sourceRect = view.bounds
                present(controller, animated: true, completion: nil)
            default:
                return
            }
            
        default:
            return
        }
    }
}

