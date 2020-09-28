//
//  NewsAttachments.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 20.09.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import Foundation
import RealmSwift

class NewsAttachments: Object, Decodable {
    @objc dynamic var type: String = ""
    @objc dynamic var photo: NewsAttachmentsPhoto?
    @objc dynamic var link: NewsAttachmentsLink?
}
