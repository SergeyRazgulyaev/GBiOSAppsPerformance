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
    @IBOutlet private weak var newsPhotoImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var newsPostTextHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var postTextShowButton: UIButton!
    
    //MARK: - Base properties
    private var isPostTextShowButtonPressed: Bool = false
    private var originalPostTextHeight: CGFloat = 95
    private let maximumPostTextHeight: CGFloat = 195
    private let postTextLabelSideInsets: CGFloat = 20
    var postTextShowButtonAction: (() -> ())?

    //MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    //MARK: - Configuration Methods
    
    func configure() {
        newsForMeAvatarView.layer.cornerRadius = newsForMeAvatarView.bounds.width / 2
        newsForMeAvatarView.layer.shadowColor = UIColor.black.cgColor
        newsForMeAvatarView.layer.shadowRadius = 5
        newsForMeAvatarView.layer.shadowOpacity = 1
        newsForMeAvatarView.layer.shadowOffset = .zero
        newsForMeAvatarView.layer.shadowPath = UIBezierPath(ovalIn: newsForMeAvatarView.bounds).cgPath
        
        newsForMeAvatarImageView.layer.cornerRadius = newsForMeAvatarImageView.bounds.width / 2
        newsForMeAvatarImageView.clipsToBounds = true
    }
    
    func configureNewsDateLabelText(newsDateLabelText: String) {
        newsDateLabel.text = newsDateLabelText
    }
    
    func configurePostTextLabelText(postTextLabelText: String) {
        postTextLabel.text = postTextLabelText
    }
    
    func configureNewsAuthorNameLabelText(newsAuthorNameLabelText: String) {
        newsAuthorNameLabel.text = newsAuthorNameLabelText
    }
    
    func configureNewsForMeImage(newsForMeImage: UIImage, photoHeight: CGFloat) {
        newsForMeImageView.image = newsForMeImage
        newsPhotoImageHeightConstraint.constant = ceil(photoHeight)
    }
    
    func configureNewsForMeAvatarImageView(newsForMeAvatarImage: UIImage) {
        newsForMeAvatarImageView.image = newsForMeAvatarImage
    }
    
    func configurePostTextShowButtonLabel(label: String, state: UIControl.State) {
        postTextShowButton.setTitle(label, for: state)
    }
    
    func configureNewsPostTextHeightConstraint(height: CGFloat) {
        newsPostTextHeightConstraint.constant = height
    }
    
    func comfigureOriginalPostTextHeight(postTextHeight: CGFloat) {
        originalPostTextHeight = postTextHeight
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
    func getPostTextLabel() -> String {
        postTextLabel.text ?? ""
    }
    func getOriginalPostTextHeight() -> CGFloat {
        originalPostTextHeight
    }
    func getNewsPostTextHeightConstraint() -> CGFloat {
        newsPostTextHeightConstraint.constant
    }
    func getСellHeightIncrement() -> CGFloat {
        newsPostTextHeightConstraint.constant - originalPostTextHeight
    }

    func getIsPostTextShowButtonPressedStatus() -> Bool {
        isPostTextShowButtonPressed
    }
    
    func calculateLabelHeight(text: String, font: UIFont) -> CGFloat {
        let maxWidth = bounds.width - (2 * postTextLabelSideInsets)
        let maxHeight = CGFloat(Int.max)
        
        let titleLabelTextBlockSize = CGSize(
            width: maxWidth,
            height: maxHeight)
        
        let curText = text as NSString
        
        let rect = curText.getBoundingRect(
            textBlock: titleLabelTextBlockSize,
            font: font)
        
        let height = ceil(rect.size.height)
//        let width = rect.size.width
//        let size = CGSize(width: ceil(width), height: ceil(height))
        return height
    }
    
    @IBAction func onPostTextShowButtonPress(_ sender: UIButton) {
        if isPostTextShowButtonPressed {
            newsPostTextHeightConstraint.constant = originalPostTextHeight
            isPostTextShowButtonPressed = false
            postTextShowButton.setTitle("Show more...", for: .normal)
            
        } else {
            let calculatedLabelHeight = calculateLabelHeight(text: postTextLabel.text ?? "", font: .boldSystemFont(ofSize: 14))
            print("calculatedLabelHeight \(calculatedLabelHeight)")
            if calculatedLabelHeight < originalPostTextHeight {
                newsPostTextHeightConstraint.constant = originalPostTextHeight
            } else {
                newsPostTextHeightConstraint.constant = maximumPostTextHeight
            }
            isPostTextShowButtonPressed = true
            postTextShowButton.setTitle("...hide", for: .normal)
        }
        postTextShowButtonAction?()
    }
}
