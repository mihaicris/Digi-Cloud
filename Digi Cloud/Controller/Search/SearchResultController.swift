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
    var filteredMountsDictionary: [String: Mount] = [:]

    weak var searchController: UISearchController?

    private let location: Location

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

    init(location: Location) {
        self.location = location
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

        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SearchCell.self),
                                                       for: indexPath) as? SearchCell else {
            return UITableViewCell()
        }

        let node = filteredContent[indexPath.row]

        guard let nodeMountName = filteredMountsDictionary[node.mountId]?.name else {
            return UITableViewCell()
        }

        guard let searchedText = searchController?.searchBar.text else {
            return UITableViewCell()
        }

        cell.nodeMountLabel.text = nodeMountName
        cell.nodePathLabel.text = node.path

        if node.type == "dir" {
            cell.nodeIcon.image = #imageLiteral(resourceName: "folder_icon")
            cell.nodeNameLabel.font = UIFont.fontHelveticaNeueMedium(size: 16)
        } else {
            cell.nodeIcon.image = #imageLiteral(resourceName: "file_icon")
            cell.nodeNameLabel.font = UIFont.fontHelveticaNeue(size: 16)
        }

        if mountNames[nodeMountName] == nil {
            mountNames[nodeMountName] = currentColor
            var hue: CGFloat = 0
            var saturation: CGFloat = 0
            var brightness: CGFloat = 0
            var alpha: CGFloat = 0
            _ = currentColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            currentColor = UIColor.init(hue: hue + 0.15, saturation: saturation, brightness: brightness, alpha: alpha)
        }
        cell.mountBackgroundColor = mountNames[nodeMountName]

        let name = node.name
        let attributedText = NSMutableAttributedString(string: name)

        let nsString = NSString(string: name.lowercased())
        let nsRange = nsString.range(of: searchedText.lowercased())

        let backGrdColor = UIColor.init(red: 1.0, green: 0.88, blue: 0.88, alpha: 1.0)
        attributedText.addAttributes([NSAttributedStringKey.backgroundColor: backGrdColor], range: nsRange)
        cell.nodeNameLabel.attributedText = attributedText

        // Identification of the button's row that tapped
        cell.seeInFolderButton.tag = indexPath.row
        cell.seeInFolderButton.addTarget(self, action: #selector(handleSeeInFolderButtonTouched(_:)), for: .touchUpInside)

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        let nodeHit = filteredContent[indexPath.row]

        guard let nodeHitMount = filteredMountsDictionary[nodeHit.mountId] else {
            print("Could not select the mount from results.")
            return
        }

        let nodeHitLocation = Location(mount: nodeHitMount, path: nodeHit.path)

        let controller = nodeHit.type == "dir"
            ? ListingViewController(location: nodeHitLocation, action: .noAction)
            : ContentViewController(location: nodeHitLocation)

        let nav = self.parent?.presentingViewController?.navigationController as? MainNavigationController

        searchController?.searchBar.resignFirstResponder()
        nav?.pushViewController(controller, animated: true)
    }

    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.searchController?.searchBar.resignFirstResponder()
    }

    // MARK: - Helper Functions

    private func setupTableView() {
        tableView.register(SearchCell.self, forCellReuseIdentifier: String(describing: SearchCell.self))
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.rowHeight = AppSettings.tableViewRowHeight
        tableView.separatorStyle = .none
    }

    @objc private func handleSeeInFolderButtonTouched(_ button: UIButton) {

        let nodeHit = filteredContent[button.tag]

        guard let nodeHitMount = filteredMountsDictionary[nodeHit.mountId] else {
            print("Could not select the mount from results.")
            return
        }

        let parentFolderLocation = Location(mount: nodeHitMount, path: nodeHit.path).parentLocation

        let controller = ListingViewController(location: parentFolderLocation,
                                               action: .showSearchResult,
                                               searchResult: nodeHit.name)

        let nav = self.parent?.presentingViewController?.navigationController as? MainNavigationController

        searchController?.searchBar.resignFirstResponder()

        nav?.pushViewController(controller, animated: true)
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

        let count = searchText.count
        if count < 3 {
            if count == 0 {
                self.filteredContent.removeAll()
                self.tableView.reloadData()
            }
            return
        }
        searchInCurrentMount = scope == 0 ? true  : false

        var parameters: [String: String] = [
            ParametersKeys.QueryString: searchText
        ]

        if scope == 0 {
            parameters[ParametersKeys.MountID] = location.mount.identifier
            parameters[ParametersKeys.Path] = location.path
        }

        // cancel search task in execution
        DigiClient.shared.task?.cancel()

        DigiClient.shared.search(parameters: parameters) { nodeHitsResult, mountsDictionaryResult, error in

            guard error == nil else {
                print("Error: \(error!.localizedDescription)")
                return
            }

            self.filteredContent = nodeHitsResult ?? []
            self.filteredMountsDictionary = mountsDictionaryResult ?? [:]

            self.filteredContent.sort {
                if $0.type == $1.type {
                    return $0.score > $1.score
                } else {
                    return $0.type < $1.type
                }
            }
            self.tableView.reloadData()
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
