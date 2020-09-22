//
//  NewsItems.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 20.09.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import Foundation
import RealmSwift

class NewsItems: Object, Decodable {
    @objc dynamic var sourceID: Int = 0
    @objc dynamic var date: Int = 0
    @objc dynamic var photos: NewsItemsPhotos?
    @objc dynamic var text: String = ""
    //    var newsCopyHistory = List<NewsCopyHistory>()
    var newsAttachments = List<NewsAttachments>()
    @objc dynamic var likes: NewsLikes?
    @objc dynamic var comments: NewsComments?
    @objc dynamic var reposts: NewsReposts?
    @objc dynamic var views: NewsItemsViews?
    @objc dynamic var type: String = ""
    @objc dynamic var postID: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case sourceID = "source_id"
        case date
        case photos
        case text
        //        case newsCopyHistory = "copy_history"
        case newsAttachments = "attachments"
        case likes
        case comments
        case reposts
        case views
        case type
        case postID = "post_id"
    }
    
    public required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        sourceID = try container.decode(Int.self, forKey: .sourceID)
        date = try container.decode(Int.self, forKey: .date)
        photos = try container.decodeIfPresent(NewsItemsPhotos.self, forKey: .photos)
        text = try container.decode(String.self, forKey: .text)
        //        newsCopyHistory = try container.decodeIfPresent(List<NewsCopyHistory>.self, forKey: .newsCopyHistory) ?? List<NewsCopyHistory>()
        newsAttachments = try container.decodeIfPresent(List<NewsAttachments>.self, forKey: .newsAttachments) ?? List<NewsAttachments>()
        likes = try container.decodeIfPresent(NewsLikes.self, forKey: .likes)
        comments = try container.decodeIfPresent(NewsComments.self, forKey: .comments)
        reposts = try container.decodeIfPresent(NewsReposts.self, forKey: .reposts)
        views = try container.decodeIfPresent(NewsItemsViews.self, forKey: .views)
        type = try container.decode(String.self, forKey: .type)
        postID = try container.decode(Int.self, forKey: .postID)
    }
    
    override class func primaryKey() -> String? {
        return "date"
    }
}
