//
//  NewsViewController.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 21.07.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import UIKit

class NewsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            
            tableView.register(NewsPostCell.self, forCellReuseIdentifier: newsPostCellIdentifier)
            tableView.register(UINib(nibName: newsPostCellNibName, bundle: nil), forCellReuseIdentifier: newsPostCellIdentifier)
            
            tableView.register(NewsPhotoCell.self, forCellReuseIdentifier: newsPhotoCellIdentifier)
            tableView.register(UINib(nibName: newsPhotoCellNibName, bundle: nil), forCellReuseIdentifier: newsPhotoCellIdentifier)
        }
    }
    
    //MARK: - Base properties
    var newsListsTypesLoadedFromNetwork: [String] = []
    
    //MARK: - Cell properties
    let newsPostCellIdentifier = "NewsPostCellIdentifier"
    let newsPostCellNibName = "NewsPostCell"
    let newsPhotoCellIdentifier = "NewsPhotoCellIdentifier"
    let newsPhotoCellNibName = "NewsPhotoCell"
    
    //MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        newsListsTypesLoadedFromNetwork = ["post", "photo", "post"]
    }
}

//MARK: - TableView Customization
extension NewsViewController: UITableViewDataSource {
    
    //MARK: - Number Of Rows In Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsListsTypesLoadedFromNetwork.count
    }
    
    //MARK: - Cell For Row At IndexPath
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch newsListsTypesLoadedFromNetwork[indexPath.row] {
        case "post":
            guard let cell = tableView.dequeueReusableCell(withIdentifier: newsPostCellIdentifier) as? NewsPostCell else { fatalError() }
            cell.newsAuthorNameLabel.text = newsForMe[indexPath.row].newsForMeSender
            cell.newsDateLabel.text = dateTranslator(timeToTranslate: Int.random(in: 1595000000...1600000000))
            cell.postTextLabel.text = newsForMe[indexPath.row].newsForMeShortText
            cell.newsForMeImageView.image = newsForMe[indexPath.row].newsForMeImage
            cell.newsForMeAvatarImageView.image = newsForMe[indexPath.row].newsForMeAvatarImage
            return cell
        case "photo":
            guard let cell = tableView.dequeueReusableCell(withIdentifier: newsPhotoCellIdentifier) as? NewsPhotoCell else { fatalError() }
            cell.newsAuthorNameLabel.text = newsForMe[indexPath.row].newsForMeSender
            cell.newsDateLabel.text = dateTranslator(timeToTranslate: Int.random(in: 1595000000...1600000000))
            cell.newsForMeImageView.image = newsForMe[indexPath.row].newsForMeImage
            cell.newsForMeAvatarImageView.image = newsForMe[indexPath.row].newsForMeAvatarImage
            return cell
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: newsPhotoCellIdentifier) as? NewsPhotoCell else { fatalError() }
            cell.newsAuthorNameLabel.text = newsForMe[indexPath.row].newsForMeSender
            cell.newsDateLabel.text = dateTranslator(timeToTranslate: Int.random(in: 1595000000...1600000000))
            cell.newsForMeImageView.image = newsForMe[indexPath.row].newsForMeImage
            cell.newsForMeAvatarImageView.image = newsForMe[indexPath.row].newsForMeAvatarImage
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch newsListsTypesLoadedFromNetwork[indexPath.row] {
        case "post":
            return 710
        case "photo":
            return 590
        default:
            return 590
        }
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
