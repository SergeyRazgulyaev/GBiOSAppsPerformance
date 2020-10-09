//
//  NewsViewController.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 21.07.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import UIKit

class NewsViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    //MARK: - Base properties
    private var dateTextCache: [IndexPath : String] = [:]
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = DateFormatter.Style.long
        return df
    }()
    private var sourceIDChecker: Int = 0
    
    //MARK: - Cell properties
    private let newsPostCellIdentifier = "NewsPostCellIdentifier"
    private let newsPostCellNibName = "NewsPostCell"
    private let newsPhotoCellIdentifier = "NewsPhotoCellIdentifier"
    private let newsPhotoCellNibName = "NewsPhotoCell"
    
    //MARK: - Properties for Interaction with Network
    private let networkService = NetworkService()
    private var newsFromNetwork: NewsResponse?
    private var nextFrom = ""
    private var isLoading = false
    
    //MARK: - Properties for RefreshController
    private lazy var refreshControl = UIRefreshControl()
    
    //MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        setupRefreshControl()
        loadPostNewsFromNetwork()
    }
    
    //MARK: - Configuration Methods
    func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = refreshControl
        tableView.prefetchDataSource = self
        tableView.register(UINib(nibName: newsPostCellNibName, bundle: nil), forCellReuseIdentifier: newsPostCellIdentifier)
    }

}

//MARK: - Refresh Method (Pull-to-refresh Pattern)
extension NewsViewController {
    fileprivate func setupRefreshControl() {
        refreshControl.attributedTitle = NSAttributedString(string: "Refresh News...", attributes: [.font: UIFont.systemFont(ofSize: 10)])
        refreshControl.tintColor = .systemGreen
        refreshControl.addTarget(self, action: #selector(refreshNews), for: .valueChanged)
    }
    
    @objc private func refreshNews() {
        self.refreshControl.beginRefreshing()
        let mostFreshNewsDate = self.newsFromNetwork?.items.first?.date ?? Date().timeIntervalSince1970
        networkService.loadNews(
            token: Session.instance.token,
            typeOfNews: .post,
            startTime: (mostFreshNewsDate + 1),
            startFrom: ""
        ) { [weak self] result in
            switch result {
            case let .success(refreshedNews):
                guard refreshedNews.items.count > 0 else { return }
                
                self?.newsFromNetwork?.items = refreshedNews.items + (self?.newsFromNetwork?.items ?? [])
                self?.newsFromNetwork?.groups = refreshedNews.groups + (self?.newsFromNetwork?.groups ?? [])
                self?.newsFromNetwork?.profiles = refreshedNews.profiles + (self?.newsFromNetwork?.profiles ?? [])
                
                let indexPathes = refreshedNews.items.enumerated().map { offset, element in
                    IndexPath(row: offset, section: 0)
                }
                self?.tableView.insertRows(at: indexPathes, with: .automatic)
            case let .failure(error):
                print(error)
            }
        }
        self.refreshControl.endRefreshing()
    }
}

//MARK: - Interaction with Network
extension NewsViewController {
    func loadPostNewsFromNetwork(completion: (() -> Void)? = nil) {
        networkService.loadNews(token: Session.instance.token, typeOfNews: .post, startTime: nil, startFrom: "") { [weak self] result in
            switch result {
            case let .success(news):
                self?.newsFromNetwork = news
                self?.tableView.reloadData()
                completion?()
            case let .failure(error):
                print(error)
            }
        }
    }
}


//MARK: - TableView Data Source Prefetching Methods
extension NewsViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard indexPaths.contains(where: isLoadingCell(for:)) else { return }
        networkService.loadNews(token: Session.instance.token, typeOfNews: .post, startTime: nil, startFrom: Session.instance.newsNextFrom) { [weak self] result in
            switch result {
            case let .success(prefetchedPostNews):
                guard prefetchedPostNews.items.count > 0 else { return }
                
                self?.newsFromNetwork?.items = (self?.newsFromNetwork?.items ?? []) + (prefetchedPostNews.items)
                self?.newsFromNetwork?.groups = (self?.newsFromNetwork?.groups ?? []) + (prefetchedPostNews.groups)
                self?.newsFromNetwork?.profiles = (self?.newsFromNetwork?.profiles ?? []) + (prefetchedPostNews.profiles)
                
                self?.tableView.reloadData()
                
            case let .failure(error):
                print(error)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
//        print("cancelPrefetchingForRowsAt \(indexPaths.first?.row ?? -1)")
    }
    
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        let newsCount = self.newsFromNetwork?.items.count ?? 0
        return indexPath.row == newsCount - 3
    }
}


//MARK: - TableView Data Source Methods
extension NewsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsFromNetwork?.items.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        configureNewsCell(indexPath: indexPath)
    }
    
    func configureNewsCell(indexPath: IndexPath) -> UITableViewCell {
        let newsCell = tableView.dequeueReusableCell(withIdentifier: newsPostCellIdentifier, for: indexPath) as? NewsPostCell
        guard let cell = newsCell, let news = newsFromNetwork else {
            print("Error with News Cell")
            return UITableViewCell()
        }
        cell.postTextShowButtonAction = {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
        sourceIDChecker = news.items[indexPath.row].sourceID
        
        var photoRatio: CGFloat = 1.0
        
        let groupOwner = news.groups.filter { $0.id == (-sourceIDChecker) }.first
        let friendOwner = news.profiles.filter { $0.id == sourceIDChecker }.first
        
        cell.getNewsLikeIndicator().configureNewsLikeLabelText(newsLikeLabelText: String(news.items[indexPath.row].likes.count))
        cell.getNewsCommentIndicator().configureNewsCommentLabelText(newsCommentLabelText: String(news.items[indexPath.row].comments.count))
        cell.getNewsShareIndicator().configureNewsShareLabelText(newsShareLabelText: String(news.items[indexPath.row].reposts.count))
        cell.getNewsViewsIndicator().configureNewsViewsLabelText(newsViewsLabelText: String(news.items[indexPath.row].views.count))
        
        // Filling the Cell depending on the News Source
        switch sourceIDChecker {
        case (-Int.max ..< 0): // Groups Cell
            cell.configureNewsAuthorNameLabelText(newsAuthorNameLabelText: groupOwner?.name ?? "")
            cell.comfigureOriginalPostTextHeight(postTextHeight: 95)
            let newsPostSourceAvatarImage = groupOwner?.photo100 ?? ""
            guard let newsPostSourceAvatarImageURL = URL(string: newsPostSourceAvatarImage), let newsPostSourceAvatarImageData = try? Data(contentsOf: newsPostSourceAvatarImageURL) else { return cell }
            cell.configureNewsForMeAvatarImageView(newsForMeAvatarImage: (UIImage(data: newsPostSourceAvatarImageData) ?? UIImage(systemName: "tortoise.fill"))!)
            
            let postText = news.items[indexPath.row].text ?? ""
            cell.configureNewsDateLabelText(newsDateLabelText: getCellDateText(forIndexPath: indexPath, andTimeToTranslate: Double(news.items[indexPath.row].date)))
            cell.configurePostTextLabelText(postTextLabelText: postText)
            
            // Cell formation depending on the Post Type (if Link)
            if news.items[indexPath.row].newsAttachments?.first?.type == "link" {
                let pathForPhoto = news.items[indexPath.row].newsAttachments?[0].link?.photo?.sizes.first
                let photoWidth = pathForPhoto?.width
                let photoHeight = pathForPhoto?.height
                
                guard photoHeight != nil, photoWidth != nil else {
                    cell.configureNewsForMeImage(newsForMeImage: UIImage(systemName: "tortoise.fill")!, photoHeight: tableView.frame.width / photoRatio)
                    return cell
                }
                if photoHeight != 0 {
                    photoRatio = CGFloat(photoWidth!) / CGFloat(photoHeight!)
                }
                let calculatedPhotoHeight = tableView.frame.width / photoRatio
                
                let newsPostPhoto = pathForPhoto?.url ?? ""
                guard let url = URL(string: newsPostPhoto), let data = try? Data(contentsOf: url) else { return cell }
                cell.configureNewsForMeImage(newsForMeImage: (UIImage(data: data) ?? UIImage(systemName: "tortoise.fill"))!, photoHeight: calculatedPhotoHeight)
            }
            
            // Cell formation depending on the Post Type (if Photo)
            if news.items[indexPath.row].newsAttachments?.first?.type == "photo" {
                let pathForPhoto = news.items[indexPath.row].newsAttachments?.first?.photo?.sizes.last
                let photoWidth = pathForPhoto?.width
                let photoHeight = pathForPhoto?.height
                
                guard photoHeight != nil, photoWidth != nil else {
                    cell.configureNewsForMeImage(newsForMeImage: UIImage(systemName: "tortoise.fill")!, photoHeight: tableView.frame.width / photoRatio)
                    return cell
                }
                if photoHeight != 0 {
                    photoRatio = CGFloat(photoWidth!) / CGFloat(photoHeight!)
                }
                let calculatedPhotoHeight = tableView.frame.width / photoRatio
                
                let newsPostPhoto = pathForPhoto?.url ?? ""
                guard let url = URL(string: newsPostPhoto), let data = try? Data(contentsOf: url) else { return cell }
                cell.configureNewsForMeImage(newsForMeImage: (UIImage(data: data) ?? UIImage(systemName: "tortoise.fill"))!, photoHeight: calculatedPhotoHeight)
            }
            
            // Cell formation depending on the Post Type (if Video)
            if news.items[indexPath.row].newsAttachments?.first?.type == "video" {
                let pathForPhoto = news.items[indexPath.row].newsAttachments?.first?.video?.image?.last
                let photoWidth =  pathForPhoto?.width
                let photoHeight = pathForPhoto?.height
                
                guard photoHeight != nil, photoWidth != nil else {
                    cell.configureNewsForMeImage(newsForMeImage: UIImage(systemName: "tortoise.fill")!, photoHeight: tableView.frame.width / photoRatio)
                    return cell
                }
                if photoHeight != 0 {
                    photoRatio = CGFloat(photoWidth!) / CGFloat(photoHeight!)
                }
                let calculatedPhotoHeight = tableView.frame.width / photoRatio
                
                let newsPostVideoImage = pathForPhoto?.url ?? ""
                guard let url = URL(string: newsPostVideoImage), let data = try? Data(contentsOf: url) else { return cell }
                cell.configureNewsForMeImage(newsForMeImage: (UIImage(data: data) ?? UIImage(systemName: "tortoise.fill"))!, photoHeight: calculatedPhotoHeight)
            }
            return cell
            
        case (1 ... Int.max): // Friends Cell
            cell.configureNewsAuthorNameLabelText(newsAuthorNameLabelText:(friendOwner?.firstName ?? "") + (" ") +  (friendOwner?.lastName ?? ""))
            
            let newsPostSourceAvatarImage = friendOwner?.photo100 ?? ""
            guard let newsPostSourceAvatarImageURL = URL(string: newsPostSourceAvatarImage), let newsPostSourceAvatarImageData = try? Data(contentsOf: newsPostSourceAvatarImageURL) else { return cell }
            cell.configureNewsForMeAvatarImageView(newsForMeAvatarImage: (UIImage(data: newsPostSourceAvatarImageData) ?? UIImage(systemName: "tortoise.fill"))!)
            
            // Checking for any Data in NewsCopyHistory
            if news.items[indexPath.row].newsCopyHistory?.first?.date != nil {
                let postText = news.items[indexPath.row].newsCopyHistory?.first?.text ?? ""
                cell.configurePostTextLabelText(postTextLabelText: postText)
                cell.configureNewsDateLabelText(newsDateLabelText: getCellDateText(forIndexPath: indexPath, andTimeToTranslate: Double(news.items[indexPath.row].newsCopyHistory?.first?.date ?? 0)))
                
                // Cell formation depending on the Post Type (if Link)
                if news.items[indexPath.row].newsCopyHistory?.first?.newsAttachments?.first?.type == "link" {
                    let pathForPhoto = news.items[indexPath.row].newsCopyHistory?.first?.newsAttachments?[0].link?.photo?.sizes.first
                    let photoWidth = pathForPhoto?.width
                    let photoHeight = pathForPhoto?.height
                    
                    guard photoHeight != nil, photoWidth != nil else {
                        cell.configureNewsForMeImage(newsForMeImage: UIImage(systemName: "tortoise.fill")!, photoHeight: tableView.frame.width / photoRatio)
                        return cell
                    }
                    if photoHeight != 0 {
                        photoRatio = CGFloat(photoWidth!) / CGFloat(photoHeight!)
                    }
                    let calculatedPhotoHeight = tableView.frame.width / photoRatio
                    
                    let newsPostPhoto = pathForPhoto?.url ?? ""
                    guard let url = URL(string: newsPostPhoto), let data = try? Data(contentsOf: url) else { return cell }
                    cell.configureNewsForMeImage(newsForMeImage: (UIImage(data: data) ?? UIImage(systemName: "tortoise.fill"))!, photoHeight: calculatedPhotoHeight)
                }
                
                // Cell formation depending on the Post Type (if Photo)
                if news.items[indexPath.row].newsCopyHistory?.first?.newsAttachments?.first?.type == "photo" {
                    let pathForPhoto = news.items[indexPath.row].newsCopyHistory?.first?.newsAttachments?.first?.photo?.sizes.last
                    let photoWidth = pathForPhoto?.width
                    let photoHeight = pathForPhoto?.height
                    
                    guard photoHeight != nil, photoWidth != nil else {
                        cell.configureNewsForMeImage(newsForMeImage: UIImage(systemName: "tortoise.fill")!, photoHeight: tableView.frame.width / photoRatio)
                        return cell
                    }
                    if photoHeight != 0 {
                        photoRatio = CGFloat(photoWidth!) / CGFloat(photoHeight!)
                    }
                    let calculatedPhotoHeight = tableView.frame.width / photoRatio
                    
                    let newsPostPhoto = pathForPhoto?.url ?? ""
                    guard let url = URL(string: newsPostPhoto), let data = try? Data(contentsOf: url) else { return cell }
                    cell.configureNewsForMeImage(newsForMeImage: (UIImage(data: data) ?? UIImage(systemName: "tortoise.fill"))!, photoHeight: calculatedPhotoHeight)
                }
                
                // Cell formation depending on the Post Type (if Video)
                if news.items[indexPath.row].newsCopyHistory?.first?.newsAttachments?.first?.type == "video" {
                    let pathForPhoto = news.items[indexPath.row].newsCopyHistory?.first?.newsAttachments?.first?.video?.image?.last
                    let photoWidth = pathForPhoto?.width
                    let photoHeight = pathForPhoto?.height
                    
                    guard photoHeight != nil, photoWidth != nil else {
                        cell.configureNewsForMeImage(newsForMeImage: UIImage(systemName: "tortoise.fill")!, photoHeight: tableView.frame.width / photoRatio)
                        return cell
                    }
                    if photoHeight != 0 {
                        photoRatio = CGFloat(photoWidth!) / CGFloat(photoHeight!)
                    }
                    let calculatedPhotoHeight = tableView.frame.width / photoRatio
                    
                    let newsPostVideoImage = pathForPhoto?.url ?? ""
                    guard let url = URL(string: newsPostVideoImage), let data = try? Data(contentsOf: url) else { return cell }
                    cell.configureNewsForMeImage(newsForMeImage: (UIImage(data: data) ?? UIImage(systemName: "tortoise.fill"))!, photoHeight: calculatedPhotoHeight)
                }
                
            } else { // In the absence of any Data in NewsCopyHistory
                let postText = news.items[indexPath.row].text ?? ""
                cell.configurePostTextLabelText(postTextLabelText: postText)
                cell.configureNewsDateLabelText(newsDateLabelText: getCellDateText(forIndexPath: indexPath, andTimeToTranslate: Double(news.items[indexPath.row].date)))
                
                if news.items[indexPath.row].newsAttachments?.first?.type == "link" {
                    let pathForPhoto = news.items[indexPath.row].newsAttachments?[0].link?.photo?.sizes.first
                    let photoWidth = pathForPhoto?.width
                    let photoHeight = pathForPhoto?.height
                    
                    guard photoHeight != nil, photoWidth != nil else {
                        cell.configureNewsForMeImage(newsForMeImage: UIImage(systemName: "tortoise.fill")!, photoHeight: tableView.frame.width / photoRatio)
                        return cell
                    }
                    if photoHeight != 0 {
                        photoRatio = CGFloat(photoWidth!) / CGFloat(photoHeight!)
                    }
                    let calculatedPhotoHeight = tableView.frame.width / photoRatio
                    
                    let newsPostPhoto = pathForPhoto?.url ?? ""
                    guard let url = URL(string: newsPostPhoto), let data = try? Data(contentsOf: url) else { return cell }
                    cell.configureNewsForMeImage(newsForMeImage: (UIImage(data: data) ?? UIImage(systemName: "tortoise.fill"))!, photoHeight: calculatedPhotoHeight)
                }
                
                if news.items[indexPath.row].newsAttachments?.first?.type == "photo" {
                    let pathForPhoto = news.items[indexPath.row].newsAttachments?.first?.photo?.sizes.last
                    let photoWidth = pathForPhoto?.width
                    let photoHeight = pathForPhoto?.height
                    
                    guard photoHeight != nil, photoWidth != nil else {
                        cell.configureNewsForMeImage(newsForMeImage: UIImage(systemName: "tortoise.fill")!, photoHeight: tableView.frame.width / photoRatio)
                        return cell
                    }
                    if photoHeight != 0 {
                        photoRatio = CGFloat(photoWidth!) / CGFloat(photoHeight!)
                    }
                    let calculatedPhotoHeight = tableView.frame.width / photoRatio
                    
                    let newsPostPhoto = pathForPhoto?.url ?? ""
                    guard let url = URL(string: newsPostPhoto), let data = try? Data(contentsOf: url) else { return cell }
                    cell.configureNewsForMeImage(newsForMeImage: (UIImage(data: data) ?? UIImage(systemName: "tortoise.fill"))!, photoHeight: calculatedPhotoHeight)
                }
                
                // Cell formation depending on the Post Type (if Video)
                if news.items[indexPath.row].newsCopyHistory?.first?.newsAttachments?.first?.type == "video" {
                    let pathForPhoto = news.items[indexPath.row].newsAttachments?.first?.video?.image?.last
                    let photoWidth = pathForPhoto?.width
                    let photoHeight = pathForPhoto?.height
                    
                    guard photoHeight != nil, photoWidth != nil else {
                        cell.configureNewsForMeImage(newsForMeImage: UIImage(systemName: "tortoise.fill")!, photoHeight: tableView.frame.width / photoRatio)
                        return cell
                    }
                    if photoHeight != 0 {
                        photoRatio = CGFloat(photoWidth!) / CGFloat(photoHeight!)
                    }
                    let calculatedPhotoHeight = tableView.frame.width / photoRatio
                    
                    let newsPostVideoImage = pathForPhoto?.url ?? ""
                    guard let url = URL(string: newsPostVideoImage), let data = try? Data(contentsOf: url) else { return cell }
                    cell.configureNewsForMeImage(newsForMeImage: (UIImage(data: data) ?? UIImage(systemName: "tortoise.fill"))!, photoHeight: calculatedPhotoHeight)
                }
            }
            return cell
            
        default:
            return UITableViewCell()
        }
    }
}


//MARK: - TableView Delegate Methods
extension NewsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//                print(indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

//MARK: - Method for translating and caching Dates
extension NewsViewController {
    func getCellDateText(forIndexPath indexPath: IndexPath, andTimeToTranslate timeToTranslate: Double) -> String {
        if let stringDate = dateTextCache[indexPath] {
            //            print("The Date of cell \(indexPath.row) is already in the Cache")
            return stringDate
        } else {
            let date = Date(timeIntervalSince1970: timeToTranslate)
            let localDate = dateFormatter.string(from: date)
            dateTextCache[indexPath] = localDate
            //            print("The Date of cell \(indexPath.row) is written to the Сache")
            return localDate
        }
    }
}

//MARK: - Alert
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
