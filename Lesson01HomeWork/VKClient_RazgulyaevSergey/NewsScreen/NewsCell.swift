//
//  NewsCell.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 21.07.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import UIKit

class NewsCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var postTextScrollView: UIScrollView!
    @IBOutlet weak var postTextLabel: UILabel!
    @IBOutlet weak var newsForMeAvatar: UIView!
    @IBOutlet weak var newsForMeAvatarImage: UIImageView!
    @IBOutlet weak var newsForMeImage: UIImageView!
    @IBOutlet weak var newsComment: NewsComment!
    @IBOutlet weak var newsLike: NewsLike!
    @IBOutlet weak var newsShare: NewsShare!
    @IBOutlet weak var newsViews: NewsViews!
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        newsForMeAvatar.layer.cornerRadius = newsForMeAvatar.bounds.width / 2
        newsForMeAvatar.layer.shadowColor = UIColor.black.cgColor
        newsForMeAvatar.layer.shadowRadius = 5
        newsForMeAvatar.layer.shadowOpacity = 1
        newsForMeAvatar.layer.shadowOffset = .zero
        newsForMeAvatar.layer.shadowPath = UIBezierPath(ovalIn: newsForMeAvatar.bounds).cgPath
        
        newsForMeAvatarImage.layer.cornerRadius = newsForMeAvatarImage.bounds.width / 2
        newsForMeAvatarImage.clipsToBounds = true
    }
}
