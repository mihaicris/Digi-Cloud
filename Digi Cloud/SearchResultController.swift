//
//  SearchResultController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 13/12/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

class SearchResultController: UITableViewController {

    // MARK: - Properties
    var filteredContent = [Node]()
    weak var searchController: UISearchController?
    fileprivate let location: Location
    fileprivate var fileCellID: String = ""
    fileprivate let byteFormatter: ByteCountFormatter = {
        let f = ByteCountFormatter()
        f.countStyle = .binary
        f.allowsNonnumericFormatting = false
        return f
    }()
    fileprivate var searchInCurrentMount: Bool = true
    fileprivate var currentColor = UIColor(hue: 0, saturation: 0.7, brightness: 0.6, alpha: 1.0)
    fileprivate var mountNames: [String: UIColor] = [:]

    // MARK: - Initializers and Deinitializers
    init(currentLocation: Location) {
        self.location = currentLocation
        super.init(style: .plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overridden Methods and Properties

    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = .bottom
        setupTableView()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredContent.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: fileCellID, for: indexPath) as? SearchCell else {
            return UITableViewCell()
        }
        let node = filteredContent[indexPath.row]

        if node.type == "dir" {
            cell.nodeIcon.image = UIImage(named: "FolderIcon")
            cell.nodeNameLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
        } else {
            cell.nodeIcon.image = UIImage(named: "FileIcon")
            cell.nodeNameLabel.font = UIFont(name: "HelveticaNeue", size: 16)
        }
        cell.nodeNameLabel.text = node.name
        cell.nodeMountLabel.text = node.location.mount.name

        if mountNames[node.location.mount.name] == nil {
            mountNames[node.location.mount.name] = currentColor
            var _hue: CGFloat = 0
            var _saturation: CGFloat = 0
            var _brightness: CGFloat = 0
            var _alpha: CGFloat = 0
            _ = currentColor.getHue(&_hue, saturation: &_saturation, brightness: &_brightness, alpha: &_alpha)
            currentColor = UIColor.init(hue: _hue + 0.2, saturation: _saturation, brightness: _brightness, alpha: _alpha)
        }
        cell.mountBackgroundColor = mountNames[node.location.mount.name]
        cell.nodePathLabel.text = node.location.path

        if node.type == "dir" {
            cell.contentView.backgroundColor = UIColor.init(white: 0.95, alpha: 1.0)
        } else {
            cell.contentView.backgroundColor = UIColor.init(white: 1, alpha: 1.0)
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }

    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.searchController?.searchBar.resignFirstResponder()
    }

    // MARK: - Helper Functions

    fileprivate func setupTableView() {
        self.fileCellID = "SearchFileCell"
        tableView.register(SearchCell.self, forCellReuseIdentifier: fileCellID)
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.rowHeight = AppSettings.tableViewRowHeight
        tableView.separatorStyle = .none
    }

    fileprivate func filterContentForSearchText(searchText: String, scope: Int) {
        let count = searchText.characters.count
        if count < 3 {
            if count == 0 {
                self.filteredContent.removeAll()
                self.tableView.reloadData()
            }
            return
        }
        searchInCurrentMount = scope == 0 ? true  : false

        let searchLocation: Location? = scope == 0 ? self.location : nil

        DigiClient.shared.searchNodes(for: searchText, at: searchLocation) { nodes, error in
            guard error == nil else {
                print("Error: \(error!.localizedDescription)")
                return
            }
            if let nodes = nodes {
                self.filteredContent = nodes
                self.filteredContent.sort {
                    return $0.location.mount.name < $1.location.mount.name
                }
                self.tableView.reloadData()
            }
        }
    }
}

extension SearchResultController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.searchController = searchController
        self.view.isHidden = false
        filterContentForSearchText(searchText: searchController.searchBar.text!, scope: searchController.searchBar.selectedScopeButtonIndex)
    }
}

extension SearchResultController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchText: searchBar.text!, scope: selectedScope)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
