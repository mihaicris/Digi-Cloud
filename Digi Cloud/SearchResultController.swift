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

    // MARK: - Initializers and Deinitializers


    // MARK: - Overridden Methods and Properties

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    // MARK: - Helper Functions

    fileprivate func filterContentForSearchText(searchText: String, scope: Int) {
        if searchText.characters.count < 3 {
            return
        }

//        let searchLocation: Location? = scope == 0 ? self.location : nil

        DigiClient.shared.searchNodes(for: searchText, at: nil) { nodes, error in
            guard error == nil else {
                print("Error: \(error!.localizedDescription)")
                return
            }
            if let nodes = nodes {
                self.filteredContent = nodes
                // TODO: Sort results with folder first?
                self.tableView.reloadData()
            }

        }
        // TODO: reloadData in tableView
    }


}

extension SearchResultController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!,
                                   scope: searchController.searchBar.selectedScopeButtonIndex)
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


