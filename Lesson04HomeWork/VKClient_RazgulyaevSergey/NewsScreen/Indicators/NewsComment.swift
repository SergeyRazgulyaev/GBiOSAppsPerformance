//
//  NewsComment.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 21.07.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import UIKit

class NewsComment: UIControl {
    @IBOutlet private weak var newsCommentLabel: UILabel!
    
    private let newsCommentImage = UIImageView()
    private var image = UIImage()
    private var newsCommentCount: Int = Int.random(in: 0...1000)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
        addSubview(newsCommentImage)
        configureGestureRecognizer()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        configure()
    }
    
    func configure() {
        newsCommentImage.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        newsCommentImage.contentMode = .scaleAspectFit
        newsCommentImage.image = UIImage(systemName: "text.bubble")
        newsCommentImage.tintColor = .gray
        newsCommentLabel.text = "\(newsCommentCount)"
    }
    
    func configureGestureRecognizer() {
        let newsCommentTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        addGestureRecognizer(newsCommentTapRecognizer)
    }
    
    @objc func onTap(_ sender: Any?) {
        print("News Comments indicator tapped")
    }
    
    func configureNewsCommentLabelText(newsCommentLabelText: String) {
        newsCommentLabel.text = newsCommentLabelText
    }
}


