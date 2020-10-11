//
//  FriendsViewController.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 09.07.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire

class FriendsViewController: UIViewController {
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var tableView: UITableView!
    
    //MARK: - Base properties
    private var friendsNameFirstCharactersSet: Set<String> = []
    private var friendsNameFirstCharactersArray: [String] = []
    
    //MARK: - Properties for Interaction with Network
    private let networkService = NetworkService()
    private let myOperationQueue = OperationQueue()
    
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
        configureSearchBar()
        configureTableView()
        createNotification()
        loadFriendsFromNetWorkIfNeeded()
    }
    
    //MARK: - Deinit filteredFriendsNotificationToken
    deinit {
        filteredFriendsNotificationToken?.invalidate()
    }
    
    //MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "photosSegue",
            let cell = sender as? FriendCell,
            let destination = segue.destination as? PhotosViewController
        {
            destination.name = cell.getTextFromTitleLabel()
            destination.friendID = cell.getFriendAvatar().getUserID()
        }
    }
    
    //MARK: - Configuration Methods
    func configureSearchBar() {
        searchBar.delegate = self
    }
    
    func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = refreshControl
        
        let view = UIView()
        view.frame = .init(x: 0, y: 0, width: 0, height: 30)
        tableView.tableHeaderView = view
        tableView.register(UINib(nibName: "SectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "headerFirstLetter")
    }
}

//MARK: - Interaction with Network
extension FriendsViewController {
    func loadFriendsFromNetWorkIfNeeded() {
        if let friends = filteredFriends, friends.isEmpty {
            print("loadFriendsFromNetWork activated")
            loadFriendsFromNetWork()
        } else {
            print("loadFriendsFromNetWork is not active")
            friendsNameFirstCharactersArrayCreation()
        }
    }
    
    func loadFriendsFromNetWork(completion: (() -> Void)? = nil) {
        let request = NetworkService.sessionAF.request("https://api.vk.com/method/friends.get", method: .get, parameters: ["access_token": Session.instance.token, "order": "name", "fields": ["nickname", "sex", "bdate", "city", "photo_100"], "v": "5.124"])
        
        let ​getFriendsDataOperation​ = ​GetDataOperation​(request: request)
        myOperationQueue.addOperation(​getFriendsDataOperation​)
        
        let parseData = ParseFriendsData()
        parseData.addDependency(​getFriendsDataOperation​)
        myOperationQueue.addOperation(parseData)
        
        let reloadTableOfFriendsViewController = ReloadTableOfFriendsViewController(controller: self)
        reloadTableOfFriendsViewController.addDependency(parseData)
        OperationQueue.main.addOperation(reloadTableOfFriendsViewController)
        completion?()
    }
    
    @objc private func refresh(_ sender: UIRefreshControl) {
        loadFriendsFromNetWork { [weak self] in
            self?.refreshControl.endRefreshing()
        }
        friendsNameFirstCharactersArrayCreation()
    }
}

//MARK: - Interaction with Realm Database
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
    
    func writeFriendsFromNetworkToRealm(writedObjects: [UserItems]) {
        try? realmManager?.add(objects: writedObjects)
        tableView.reloadData()
    }
}

//MARK: - TableView Data Source Methods
extension FriendsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if isFiltering {
            return 1
        }
        return friendsNameFirstCharactersArray.count
    }
    
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        configureCell(indexPath: indexPath)
    }
    
    func configureCell(indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell") as? FriendCell else { return UITableViewCell() }
        if isFiltering {
            let friend = filteredFriends?[indexPath.row]
            let friendAvatarImage = friend?.photo100 ?? ""
            guard let url = URL(string: friendAvatarImage), let data = try? Data(contentsOf: url) else { return cell }
            cell.configureTitleLabel(titleLabelText: String("\(friend!.firstName) \(friend!.lastName)"))
            cell.configureFriendAvatarImage(friendAvatarImage: (UIImage(data: data) ?? UIImage(systemName: "tortoise.fill"))!)
            cell.getFriendAvatar().configureUserID(userID: filteredFriends?[indexPath.row].id ?? 0)
        } else {
            var friendsForSection: Results<UserItems>? {
                let friendsForSection: Results<UserItems>? = realmManager?.getObjects().filter("firstName BEGINSWITH '\(friendsNameFirstCharactersArray[indexPath.section])'")
                return friendsForSection
            }
            guard let url = URL(string: friendsForSection![indexPath.row].photo100), let data = try? Data(contentsOf: url) else { return cell }
            let friendName = String("\(friendsForSection![indexPath.row].firstName) \(friendsForSection![indexPath.row].lastName)")
            cell.configureTitleLabel(titleLabelText: friendName)
            cell.configureFriendAvatarImage(friendAvatarImage: (UIImage(data: data) ?? UIImage(systemName: "tortoise.fill"))!)
            cell.getFriendAvatar().tag = indexPath.row
            cell.getFriendAvatar().configureUserID(userID: friendsForSection![indexPath.row].id)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
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
    
    internal func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if isFiltering {
            let headerName = ""
            guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "headerFirstLetter") as? SectionHeader else { return UIView() }
            header.configureHeaderFirstLetterLabelText(headerFirstLetterLabelText: headerName)
            return header
        } else {
            guard friendsNameFirstCharactersArray.count > 0, tableView.numberOfRows(inSection: section) != 0 else {
                let headerName = ""
                guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "headerFirstLetter") as? SectionHeader else { return UIView() }
                header.configureHeaderFirstLetterLabelText(headerFirstLetterLabelText: headerName)
                return header
            }
            let headerName = String(friendsNameFirstCharactersArray[section].first!)
            guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "headerFirstLetter") as? SectionHeader else { return UIView() }
            header.configureHeaderFirstLetterLabelText(headerFirstLetterLabelText: headerName)
            return header
        }
    }
}

//MARK: - TableView Delegate Methods
extension FriendsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        print("Cell \(indexPath) selected")
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

//MARK: - SearchController
extension FriendsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        tableView.reloadData()
    }
}

//MARK: - Alert
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
