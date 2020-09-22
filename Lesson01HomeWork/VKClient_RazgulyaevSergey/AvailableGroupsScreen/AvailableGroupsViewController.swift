//
//  AvailableGroupsViewController.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 10.07.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import UIKit

class AvailableGroupsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView! {
        didSet{
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
 
    //MARK: - Base properties
    private var filteredAvailableGroups = [AvailableGroup]()
    
    //MARK: - Properties for SearchController
    private let searchAvailableGroupController = UISearchController(searchResultsController: nil)
    private var searchBarIsEmpty: Bool {
        guard let text = searchAvailableGroupController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchAvailableGroupController.isActive && !searchBarIsEmpty
    }
    
//MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchAvailableGroupController.searchResultsUpdater = self
               searchAvailableGroupController.obscuresBackgroundDuringPresentation = false
               searchAvailableGroupController.searchBar.placeholder = "Search Available Groups"
               navigationItem.searchController = searchAvailableGroupController
               definesPresentationContext = true
    }
}

//MARK: - TableView Customization
extension AvailableGroupsViewController: UITableViewDataSource {
   
    //MARK: - Number Of Rows In Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredAvailableGroups.count
        }
        return availableGroups.count
    }
    
    //MARK: - Cell For Row At IndexPath
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AvailableGroupCell") as? AvailableGroupCell else { fatalError() }
        var groups: AvailableGroup
        if isFiltering {
            groups = filteredAvailableGroups[indexPath.row]
        } else {
            groups = availableGroups[indexPath.row]
        }
        cell.titleLabel.text = groups.availableGroupName
        cell.availableGroupsAvatarImage.image = groups.availableGroupAvatar
//        print("Cell created for row: \(indexPath.row), \(availableGroups[indexPath.row])")
        return cell
    }
    // Deletion Available Group
    /*
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if isFiltering {
            filteredAvailableGroups.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .top)
            } else {
            availableGroups.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .top)
            }
        }
    }
     */
}

//MARK: - Did Select Row At IndexPath
extension AvailableGroupsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(indexPath)
    }
}

//MARK: - SearchController Block
extension AvailableGroupsViewController:UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        
         filteredAvailableGroups = availableGroups.filter({(group: AvailableGroup) -> Bool in
            return group.availableGroupName.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
}
