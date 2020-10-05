//
//  NewsAttachmentsPhotoSizes.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 20.09.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import Foundation
import RealmSwift

class NewsAttachmentsPhotoSizes: Object, Decodable {
    @objc dynamic var height: Int = 0
    @objc dynamic var type: String = ""
    @objc dynamic var url: String = ""
    @objc dynamic var width: Int = 0
}