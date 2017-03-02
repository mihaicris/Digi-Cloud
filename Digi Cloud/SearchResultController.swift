//
//  SearchResultController.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 13/12/16.
//  Copyright © 2016 Mihai Cristescu. All rights reserved.
//

import UIKit

final class SearchResultController: UITableViewController {

    // MARK: - Properties
    var filteredContent: [NodeHit] = []

    weak var searchController: UISearchController?

    private let node: Node

    private var fileCellID: String = ""

    private let byteFormatter: ByteCountFormatter = {
        let f = ByteCountFormatter()
        f.countStyle = .binary
        f.allowsNonnumericFormatting = false
        return f
    }()

    private var searchInCurrentMount: Bool = true
    private var currentColor = UIColor(hue: 0.17, saturation: 0.55, brightness: 0.75, alpha: 1.0)
    private var mountNames: [String: UIColor] = [:]

    // MARK: - Initializers and Deinitializers

    init(node: Node) {
        self.node = node
        super.init(style: .plain)
        INITLog(self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit { DEINITLog(self) }

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

        cell.nodeMountLabel.text = node.location.mount.name

        if mountNames[node.location.mount.name] == nil {
            mountNames[node.location.mount.name] = currentColor
            var hue: CGFloat = 0
            var saturation: CGFloat = 0
            var brightness: CGFloat = 0
            var alpha: CGFloat = 0
            _ = currentColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            currentColor = UIColor.init(hue: hue + 0.15, saturation: saturation, brightness: brightness, alpha: alpha)
        }
        cell.mountBackgroundColor = mountNames[node.location.mount.name]
        cell.nodePathLabel.text = node.location.path

        let name = node.name
        let attributedText = NSMutableAttributedString(string: name)

        guard let searchedText = searchController?.searchBar.text else {
            return cell
        }

        let nsString = NSString(string: name.lowercased())
        let nsRange = nsString.range(of: searchedText.lowercased())

        let backGrdColor = UIColor.init(red: 1.0, green: 0.88, blue: 0.88, alpha: 1.0)
        attributedText.addAttributes([NSBackgroundColorAttributeName: backGrdColor], range: nsRange)
        cell.nodeNameLabel.attributedText = attributedText

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        searchController?.searchBar.resignFirstResponder()
        let item = filteredContent[indexPath.row]

        let resultNode = Node(name: item.name, type: item.type, modified: item.modified,
                              size: item.size, contentType: item.contentType, hash: nil, share: nil,
                              downloadLink: nil, uploadLink: nil, parentLocation: item.location.parentLocation)

        let controller = item.type == "dir" ? ListingViewController(node: resultNode, action: .noAction) : ContentViewController(item: item)

        let nav = self.parent?.presentingViewController?.navigationController as? MainNavigationController
        nav?.pushViewController(controller, animated: true)
    }

    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.searchController?.searchBar.resignFirstResponder()
    }

    // MARK: - Helper Functions

    private func setupTableView() {
        self.fileCellID = "SearchFileCell"
        tableView.register(SearchCell.self, forCellReuseIdentifier: fileCellID)
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.rowHeight = AppSettings.tableViewRowHeight
        tableView.separatorStyle = .none
    }

    fileprivate func filterContentForSearchText(searchText: String, scope: Int) {

        /* 
         Request parameters:
         
             query: Option[String]
             offset: Int
             limit: Int
             sortField: String
             sortDir: String // asc or desc
             mime: String     TODO?
             mountId: String
             path: String
             tags: Seq[String] // format: tag=nameoftag=value
         */

        let count = searchText.characters.count
        if count < 3 {
            if count == 0 {
                self.filteredContent.removeAll()
                self.tableView.reloadData()
            }
            return
        }
        searchInCurrentMount = scope == 0 ? true  : false

        var parameters: [String: String] = [
            ParametersKeys.QueryString: searchText,
        ]

        if scope == 0 {
            parameters[ParametersKeys.MountID] = self.node.location.mount.id
            parameters[ParametersKeys.Path] = self.node.location.path
        }

        DigiClient.shared.search(parameters: parameters) { results, error in
            guard error == nil else {
                print("Error: \(error!.localizedDescription)")
                return
            }
            if var nodes = results {
                nodes.sort {
                    if $0.type == $1.type {
                        return $0.score > $1.score
                    } else {
                        return $0.type < $1.type
                    }
                }
                self.filteredContent = nodes

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
