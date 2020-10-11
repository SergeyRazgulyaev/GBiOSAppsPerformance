//
//  NewsPostCell.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 21.07.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import UIKit

class NewsPostCell: UITableViewCell {
    @IBOutlet private weak var newsAuthorNameLabel: UILabel!
    @IBOutlet private weak var newsDateLabel: UILabel!
    @IBOutlet private weak var postTextScrollView: UIScrollView!
    @IBOutlet private weak var postTextLabel: UILabel!
    @IBOutlet private weak var newsForMeAvatarView: UIView!
    @IBOutlet private weak var newsForMeAvatarImageView: UIImageView!
    @IBOutlet private weak var newsForMeImageView: UIImageView!
    @IBOutlet private weak var newsLikeIndicator: NewsLike!
    @IBOutlet private weak var newsCommentIndicator: NewsComment!
    @IBOutlet private weak var newsShareIndicator: NewsShare!
    @IBOutlet private weak var newsViewsIndicator: NewsViews!
    
    //MARK: - Lifecycle
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
    
    //MARK: - Configuration Methods
    func configureNewsDateLabelText(newsDateLabelText: String) {
        newsDateLabel.text = newsDateLabelText
    }
    
    func configurePostTextLabelText(postTextLabelText: String) {
        postTextLabel.text = postTextLabelText
    }
    
    func configureNewsAuthorNameLabelText(newsAuthorNameLabelText: String) {
        newsAuthorNameLabel.text = newsAuthorNameLabelText
    }
    
    func configureNewsForMeImage(newsForMeImage: UIImage) {
        newsForMeImageView.image = newsForMeImage
    }
    
    func configureNewsForMeAvatarImageView(newsForMeAvatarImage: UIImage) {
        newsForMeAvatarImageView.image = newsForMeAvatarImage
    }
    
    //MARK: - Access Methods
    func getNewsLikeIndicator() -> NewsLike {
        newsLikeIndicator
    }
    func getNewsCommentIndicator() -> NewsComment {
        newsCommentIndicator
    }
    func getNewsShareIndicator() -> NewsShare {
        newsShareIndicator
    }
    func getNewsViewsIndicator() -> NewsViews {
        newsViewsIndicator
    }
}
