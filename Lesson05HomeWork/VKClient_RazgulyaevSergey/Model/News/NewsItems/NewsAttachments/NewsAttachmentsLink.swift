//
//  NewsAttachmentsLink.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 22.09.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import Foundation
import RealmSwift

class NewsAttachmentsLink: Object, Decodable {
    @objc dynamic var url: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var caption: String? = nil
    @objc dynamic var photo: NewsAttachmentsPhoto?
}
