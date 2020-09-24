//
//  NewsGroups.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 20.09.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import Foundation
import RealmSwift

class NewsGroups: Object, Decodable {
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var photo100: String = ""
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case photo100 = "photo_100"
    }
}
