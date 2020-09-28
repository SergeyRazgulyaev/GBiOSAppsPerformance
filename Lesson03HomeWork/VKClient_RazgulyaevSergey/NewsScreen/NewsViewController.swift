//
//  NewsViewController.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 21.07.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import UIKit
import RealmSwift

class NewsViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.refreshControl = refreshControl
            
            tableView.register(NewsPostCell.self, forCellReuseIdentifier: newsPostCellIdentifier)
            tableView.register(UINib(nibName: newsPostCellNibName, bundle: nil), forCellReuseIdentifier: newsPostCellIdentifier)
            
            tableView.register(NewsPhotoCell.self, forCellReuseIdentifier: newsPhotoCellIdentifier)
            tableView.register(UINib(nibName: newsPhotoCellNibName, bundle: nil), forCellReuseIdentifier: newsPhotoCellIdentifier)
        }
    }
    
    //MARK: - Base properties
    //    var newsListsTypesLoadedFromNetwork: [String] = []
    
    //MARK: - Cell properties
    private let newsPostCellIdentifier = "NewsPostCellIdentifier"
    private let newsPostCellNibName = "NewsPostCell"
    private let newsPhotoCellIdentifier = "NewsPhotoCellIdentifier"
    private let newsPhotoCellNibName = "NewsPhotoCell"
    
    //MARK: - Properties for Interaction with Network
    private let networkService = NetworkService()
    
    //MARK: - Properties for Interaction with Database
    private var newsNotificationToken: NotificationToken?
    private let realmManager = RealmManager.instance
    
    private var newsFromRealm: Results<NewsResponse>? {
        let newsFromRealm: Results<NewsResponse>? = realmManager?.getObjects()
        return newsFromRealm
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
        //        newsListsTypesLoadedFromNetwork = ["post", "photo", "post"]
        createNotification()
        loadPostNewsFromNetwork()
    }
    
    //MARK: - Deinit newsNotificationToken
    deinit {
        newsNotificationToken?.invalidate()
    }
}

//MARK: - Interaction with Network
extension NewsViewController {
    func loadPostNewsFromNetwork(completion: (() -> Void)? = nil) {
        networkService.loadNews(token: Session.instance.token, typeOfNews: .post) { [weak self] result in
            switch result {
            case let .success(postNews):
                print ("postNews\n \(postNews)")
                try? self?.realmManager?.add(objects: [postNews])
                completion?()
            case let .failure(error):
                print(error)
            }
        }
    }
    
    //MARK: - Refresh Block
    @objc private func refresh(_ sender: UIRefreshControl) {
        loadPostNewsFromNetwork { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }
}

//MARK: - TableView Customization
extension NewsViewController: UITableViewDataSource {
    
    //MARK: - Number Of Rows In Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsFromRealm?.first?.items.count ?? 0
    }
    
    //MARK: - Cell For Row At IndexPath
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        switch newsFromRealm[indexPath.row] {
        //        case "post":
        guard let cell = tableView.dequeueReusableCell(withIdentifier: newsPostCellIdentifier) as? NewsPostCell else { fatalError() }
        let news = newsFromRealm?.first?.items[indexPath.row]
        let newsDate = dateTranslator(timeToTranslate: news?.date ?? 0)
        let postText = news?.text ?? ""
        cell.configureNewsDateLabelText(newsDateLabelText: newsDate)
        cell.configurePostTextLabelText(postTextLabelText: postText)
        cell.newsLikeIndicator.configureNewsLikeLabelText(newsLikeLabelText: String(news!.likes!.count))
        cell.newsCommentIndicator.configureNewsCommentLabelText(newsCommentLabelText: String(news!.comments!.count))
        cell.newsShareIndicator.configureNewsShareLabelText(newsShareLabelText: String(news!.reposts!.count))
        cell.newsViewsIndicator.configureNewsViewsLabelText(newsViewsLabelText: String(news!.views!.count))
        
        if news?.newsAttachments.first?.type == "link" {
            let newsPostPhoto = news?.newsAttachments[0].link?.photo?.sizes.first?.url ?? ""
            guard let url = URL(string: newsPostPhoto), let data = try? Data(contentsOf: url) else { return cell }
            cell.configureNewsForMeImage(newsForMeImage: (UIImage(data: data) ?? UIImage(systemName: "tortoise.fill"))!)
        }
        
        if news?.newsAttachments.first?.type == "photo" {
            let newsPostPhoto = news?.newsAttachments.first?.photo?.sizes.last?.url ?? ""
            guard let url = URL(string: newsPostPhoto), let data = try? Data(contentsOf: url) else { return cell }
            cell.configureNewsForMeImage(newsForMeImage: (UIImage(data: data) ?? UIImage(systemName: "tortoise.fill"))!)
        }
        
        var filteredNewsSource: Results<NewsGroups>? {
            let filteredNewsSource: Results<NewsGroups>? = realmManager?.getObjects().filter("id == \(abs(news?.sourceID ?? 0))")
            return filteredNewsSource
        }
        cell.configureNewsAuthorNameLabelText(newsAuthorNameLabelText: filteredNewsSource?.first?.name ?? "")
        
        let newsPostSourceAvatarImage = filteredNewsSource?.first?.photo100 ?? ""
        guard let newsPostSourceAvatarImageURL = URL(string: newsPostSourceAvatarImage), let newsPostSourceAvatarImageData = try? Data(contentsOf: newsPostSourceAvatarImageURL) else { return cell }
        cell.configureNewsForMeAvatarImageView(newsForMeAvatarImage: (UIImage(data: newsPostSourceAvatarImageData) ?? UIImage(systemName: "tortoise.fill"))!)
        return cell
        
        //        case "photo":
        //            guard let cell = tableView.dequeueReusableCell(withIdentifier: newsPhotoCellIdentifier) as? NewsPhotoCell else { fatalError() }
        
        //            return cell
        //        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 600
    }
}


//MARK: - Did Select Row At IndexPath
extension NewsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        print(indexPath)
    }
}

//MARK: - Date Translation Function
extension NewsViewController {
    func dateTranslator(timeToTranslate: Int) -> String {
        var date: Date?
        date = Date(timeIntervalSince1970: Double(timeToTranslate))
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.long
        dateFormatter.timeZone = .current
        let localDate = dateFormatter.string(from: date!)
        return localDate
    }
}

//MARK: - Alert Block
extension NewsViewController {
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

//MARK: - Function for observing newsFromRealm changes
extension NewsViewController {
    private func createNotification() {
        newsNotificationToken = newsFromRealm?.observe { [weak self] change in
            switch change {
            case let . initial(newsFromRealm):
                print("Initialized \(newsFromRealm.count)")
                
            case let .update(newsFromRealm, deletions: deletions, insertions: insertions, modifications: modifications):
                print("""
                    New count: \(newsFromRealm.count)
                    Deletions: \(deletions)
                    Insertions: \(insertions)
                    Modifications: \(modifications)
                    """)
                self?.tableView.reloadData()
                
            case let .error(error):
                self?.showAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }
}

