//
//  FriendsViewController.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 09.07.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import UIKit
import RealmSwift

class FriendsViewController: UIViewController {
    @IBOutlet private weak var searchBar: UISearchBar!{
        didSet {
            searchBar.delegate = self
        }
    }
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.refreshControl = refreshControl

            
            let view = UIView()
            view.frame = .init(x: 0, y: 0, width: 0, height: 30)
            tableView.tableHeaderView = view
            tableView.register(UINib(nibName: "SectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "headerFirstLetter")
        }
    }
    
    //MARK: - Base properties
    private var friendsNameFirstCharactersSet: Set<String> = []
    private var friendsNameFirstCharactersArray: [String] = []
    private var indexPathForDelete: IndexPath?

    //MARK: - Properties for Interaction with Network
    private let networkService = NetworkService()
    
    //MARK: - Properties for Interaction with Database
    private var filteredFriendsNotificationToken: NotificationToken?
    private let realmManager = RealmManager.instance
    
    private var friendsFromRealm: Results<UserItems>? {
        let friendsFromRealm: Results<UserItems>? = realmManager?.getObjects()
        return friendsFromRealm
    }
    
    private var filteredFriends: Results<UserItems>? {
        guard !searchText.isEmpty else { return friendsFromRealm }
        return friendsFromRealm?.filter("firstName CONTAINS[cd] %@ OR lastName CONTAINS[cd] %@", searchText, searchText)
    }
    
    private var searchText: String {
        searchBar.text ?? ""
    }
    
    //MARK: - Properties for SearchController
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
        print("userID \(Session.instance.userID)")

        createNotification()
        
        //MARK: - Function loadFriendsFromNetWork activation
        if let friends = filteredFriends, friends.isEmpty {
            print("loadFriendsFromNetWork activated")
            loadFriendsFromNetWork()
        } else {
            print("loadFriendsFromNetWork is not active")
            friendsNameFirstCharactersArrayCreation()
        }
    }
    
    //MARK: - Deinit filteredGroupsNotificationToken
       deinit {
           filteredFriendsNotificationToken?.invalidate()
       }
    
    //MARK: - Segue Block
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "photosSegue",
            let cell = sender as? FriendCell,
            let destination = segue.destination as? PhotosViewController
        {
            destination.name = cell.titleLabel.text
            destination.friendID = cell.friendAvatar.userID!
        }
    }
}

//MARK: - Interaction with Network
extension FriendsViewController {
    func loadFriendsFromNetWork(completion: (() -> Void)? = nil) {
        networkService.loadFriends(token: Session.instance.token) { [weak self] result in
            switch result {
            case let .success(users):
                DispatchQueue.main.async {
                try? self?.realmManager?.add(objects: users)
                completion?()
                }
            case let .failure(error):
                print(error)
            }
        }
    }
    //MARK: - Refresh Block
    @objc private func refresh(_ sender: UIRefreshControl) {
        loadFriendsFromNetWork { [weak self] in
            self?.refreshControl.endRefreshing()
        }
        friendsNameFirstCharactersArrayCreation()
    }
}

//MARK: - TableView Customization
extension FriendsViewController: UITableViewDataSource {
    
    //MARK: - Number Of Sections
    func numberOfSections(in tableView: UITableView) -> Int {
        if isFiltering {
            return 1
        }
        return friendsNameFirstCharactersArray.count
    }
    
    //MARK: - Number Of Rows In Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredFriends?.count ?? 0
        }
        var friendsForSection: Results<UserItems>? {
            let friendsForSection: Results<UserItems>? = realmManager?.getObjects().filter("firstName BEGINSWITH '\(friendsNameFirstCharactersArray[section])'")
            return friendsForSection
        }
        return friendsForSection!.count
    }
    
    //MARK: - Cell For Row At IndexPath
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell") as? FriendCell else { fatalError() }
        
        if isFiltering {
            let friend = filteredFriends?[indexPath.row]
            let friendAvatar = friend?.photo100 ?? ""
            guard let url = URL(string: friendAvatar), let data = try? Data(contentsOf: url) else { return cell }
            cell.titleLabel.text = String("\(friend!.firstName) \(friend!.lastName)")
            cell.friendAvatarImage.image = UIImage(data: data)
            cell.friendAvatar.userID = filteredFriends?[indexPath.row].id
        } else {
            
            var friendsForSection: Results<UserItems>? {
                let friendsForSection: Results<UserItems>? = realmManager?.getObjects().filter("firstName BEGINSWITH '\(friendsNameFirstCharactersArray[indexPath.section])'")
                return friendsForSection
            }
            
            guard let url = URL(string: friendsForSection![indexPath.row].photo100), let data = try? Data(contentsOf: url) else { return cell }
            let friendName = String("\(friendsForSection![indexPath.row].firstName) \(friendsForSection![indexPath.row].lastName)")
            cell.titleLabel.text = friendName
            cell.friendAvatarImage.image = UIImage(data: data)
            cell.friendAvatar.tag = indexPath.row
            cell.friendAvatar.userID = friendsForSection![indexPath.row].id
        }
        return cell
    }
    
    //MARK: - Delete Cell For Row At IndexPath Block
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            indexPathForDelete = indexPath
            var friendsForSection: Results<UserItems>? {
                let friendsForSection: Results<UserItems>? = realmManager?.getObjects().filter("firstName BEGINSWITH '\(friendsNameFirstCharactersArray[indexPath.section])'")
                return friendsForSection
            }
            if isFiltering {
                try? realmManager?.delete(object: filteredFriends![indexPath.item])
            } else {
                try? realmManager?.delete(object: friendsForSection![indexPath.item])
            }
        }
    }
    
    //MARK: - View For Header In Section
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if isFiltering {
            let headerName = ""
            guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "headerFirstLetter") as? SectionHeader else { fatalError() }
            header.headerLabelFirstLetter.text = headerName
            return header
        } else {
            guard friendsNameFirstCharactersArray.count > 0, tableView.numberOfRows(inSection: section) != 0 else {
                let headerName = ""
                guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "headerFirstLetter") as? SectionHeader else { fatalError() }
                header.headerLabelFirstLetter.text = headerName
                return header
            }
            let headerName = String(friendsNameFirstCharactersArray[section].first!)
            guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "headerFirstLetter") as? SectionHeader else { fatalError() }
            header.headerLabelFirstLetter.text = headerName
            return header
        }
    }
}

//MARK: - Did Select Row At IndexPath
extension FriendsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

//MARK: - SearchController Block
extension FriendsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        tableView.reloadData()
    }
}

//MARK: - Alert Block
extension FriendsViewController {
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

//MARK: - Function for observing filteredGroups changes
extension FriendsViewController {
    private func createNotification() {
        filteredFriendsNotificationToken = filteredFriends?.observe { [weak self] change in
            switch change {
            case let . initial(filteredFriends):
                print("Initialized \(filteredFriends.count)")
                
            case let .update(filteredFriends, deletions: deletions, insertions: insertions, modifications: modifications):
                print("""
                    New count: \(filteredFriends.count)
                    Deletions: \(deletions)
                    Insertions: \(insertions)
                    Modifications: \(modifications)
                    """)
                self?.friendsNameFirstCharactersArrayCreation()
                self?.tableView.reloadData()

            case let .error(error):
                self?.showAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }
}

//MARK: - Preparing Data for display
extension FriendsViewController {
    func friendsNameFirstCharactersArrayCreation() {
        guard friendsFromRealm!.count > 0 else {
            print("Network error")
            return
        }
        for friend in friendsFromRealm! {
            friendsNameFirstCharactersSet.insert(String(friend.firstName.first!))
        }
        friendsNameFirstCharactersArray = friendsNameFirstCharactersSet.sorted()
    }
}
