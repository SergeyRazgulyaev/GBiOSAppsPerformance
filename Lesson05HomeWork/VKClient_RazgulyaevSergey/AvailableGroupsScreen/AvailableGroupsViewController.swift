//
//  AvailableGroupsViewController.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 10.07.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import UIKit

class AvailableGroupsViewController: UIViewController {
    @IBOutlet private weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
        }
    }
    @IBOutlet private weak var tableView: UITableView! {
        didSet{
            tableView.dataSource = self
            tableView.delegate = self
            tableView.refreshControl = refreshControl
        }
    }
    
    //MARK: - Base properties
    private var availableGroups = [GroupItems]()
    
    //MARK: - Properties for Interaction with Network
    private let networkService = NetworkService()
    
    //MARK: - Properties for Cache Service
    private var cachePhotoService: CachePhotoService?
    
    //MARK: - Properties for SearchController
    private var searchText: String {
        searchBar.text ?? ""
    }
    private var isFiltering: Bool {
        return !searchText.isEmpty
    }
    
    //MARK: - Properties for RefreshController
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .systemGreen
        refreshControl.attributedTitle = NSAttributedString(string: "Reload Data", attributes: [.font: UIFont.systemFont(ofSize: 10)])
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        return refreshControl
    }()
    
    //MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cachePhotoService = CachePhotoService(container: tableView)
    }
}

//MARK: - Interaction with Network
extension AvailableGroupsViewController {
    func loadAvailableGroupsFromNetWork() {
        networkService.loadSearchedGroups(token: Session.instance.token, searchedGroupName: searchBar.text!) { [weak self] result in
            switch result {
            case let .success(groups):
                self?.availableGroups = []
                for group in groups {
                    self?.availableGroups.append(group)
                }
//                print(groups)
                self?.tableView.reloadData()
            case let .failure(error):
                print(error)
            }
        }
    }
    
    //MARK: - Refresh Block
    @objc private func refresh(_ sender: UIRefreshControl) {
        loadAvailableGroupsFromNetWork()
        refreshControl.endRefreshing()
    }
}

//MARK: - TableView Customization
extension AvailableGroupsViewController: UITableViewDataSource {
    
    //MARK: - Number Of Rows In Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFiltering ? availableGroups.count : 0
    }
    
    //MARK: - Cell For Row At IndexPath
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        configureCell(indexPath: indexPath)
    }
    
    func configureCell(indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AvailableGroupCell") as? AvailableGroupCell else { fatalError() }
        let availableGroup = availableGroups[indexPath.row]
        let availableGroupAvatarURL = availableGroup.photo100
        let titleLabelText = availableGroup.name
        guard let image = cachePhotoService?.getPhoto(atIndexPath: indexPath, byUrl: availableGroupAvatarURL) else { return cell }
        cell.configure(
            titleLabelText: titleLabelText,
            availableGroupsAvatarImage: image)
        return cell
    }
}

//MARK: - Did Select Row At IndexPath
extension AvailableGroupsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        print(indexPath)
    }
}

//MARK: - SearchController Block
extension AvailableGroupsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        return isFiltering ? loadAvailableGroupsFromNetWork() : tableView.reloadData()
    }
}

//MARK: - Alert Block
extension AvailableGroupsViewController {
    private func showAlert(title: String? = nil,
                           message: String? = nil,
                           handler: ((UIAlertAction) -> ())? = nil,
                           completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: handler)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: completion)
    }
}
