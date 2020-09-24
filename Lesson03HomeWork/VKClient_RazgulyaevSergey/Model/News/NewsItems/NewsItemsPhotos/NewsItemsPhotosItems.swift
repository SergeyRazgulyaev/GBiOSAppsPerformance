//
//  NewsItemsPhotosItems.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 20.09.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import Foundation
import RealmSwift

class NewsItemsPhotosItems: Object, Decodable {
    @objc dynamic var date: Int = 0
    @objc dynamic var id: Int = 0
    @objc dynamic var ownerID: Int = 0
    var sizes = List<NewsItemsPhotosItemsSizes>()
    @objc dynamic var likes: NewsItemsPhotosLikes?
    @objc dynamic var reposts: NewsItemsPhotosReposts?
    @objc dynamic var comments: NewsItemsPhotosComments?
    
    enum CodingKeys: String, CodingKey {
        case date
        case id
        case ownerID = "owner_id"
        case sizes
        case likes
        case reposts
        case comments
    }
}
