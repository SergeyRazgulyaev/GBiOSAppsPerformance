//
//  NewsPostCell.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 21.07.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import UIKit

class NewsPostCell: UITableViewCell {
    @IBOutlet weak var newsAuthorNameLabel: UILabel!
    @IBOutlet weak var newsDateLabel: UILabel!
    @IBOutlet weak var postTextScrollView: UIScrollView!
    @IBOutlet weak var postTextLabel: UILabel!
    @IBOutlet weak var newsForMeAvatarView: UIView!
    @IBOutlet weak var newsForMeAvatarImageView: UIImageView!
    @IBOutlet weak var newsForMeImageView: UIImageView!
    @IBOutlet weak var newsLikeIndicator: NewsLike!
    @IBOutlet weak var newsCommentIndicator: NewsComment!
    @IBOutlet weak var newsShareIndicator: NewsShare!
    @IBOutlet weak var newsViewsIndicator: NewsViews!    

    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        newsForMeAvatarView.layer.cornerRadius = newsForMeAvatarView.bounds.width / 2
        newsForMeAvatarView.layer.shadowColor = UIColor.black.cgColor
        newsForMeAvatarView.layer.shadowRadius = 5
        newsForMeAvatarView.layer.shadowOpacity = 1
        newsForMeAvatarView.layer.shadowOffset = .zero
        newsForMeAvatarView.layer.shadowPath = UIBezierPath(ovalIn: newsForMeAvatarView.bounds).cgPath
        
        newsForMeAvatarImageView.layer.cornerRadius = newsForMeAvatarImageView.bounds.width / 2
        newsForMeAvatarImageView.clipsToBounds = true
    }
}
