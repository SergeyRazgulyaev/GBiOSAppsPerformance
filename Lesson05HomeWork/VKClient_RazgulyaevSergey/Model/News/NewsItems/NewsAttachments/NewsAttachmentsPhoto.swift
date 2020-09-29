//
//  NewsAttachmentsPhoto.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 20.09.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import Foundation
import RealmSwift

class NewsAttachmentsPhoto: Object, Decodable {
    @objc dynamic var date: Int = 0
    @objc dynamic var id: Int = 0
    @objc dynamic var ownerID: Int = 0
    var sizes = List<NewsAttachmentsPhotoSizes>()
    
    enum CodingKeys: String, CodingKey {
        case date
        case id
        case ownerID = "owner_id"
        case sizes = "sizes"
    }
}

