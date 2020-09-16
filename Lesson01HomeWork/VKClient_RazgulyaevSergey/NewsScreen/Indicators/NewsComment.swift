//
//  NewsComment.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 21.07.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import UIKit

class NewsComment: UIControl {
    @IBOutlet weak var newsCommentLabel: UILabel!
    
    let newsCommentImage = UIImageView()
    var image = UIImage()
    var newsCommentCount: Int = Int.random(in: 0...1000)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        configure()
    }
    
    func configure() {
        newsCommentImage.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        newsCommentImage.contentMode = .scaleAspectFit
        addSubview(newsCommentImage)
        newsCommentImage.image = UIImage(systemName: "text.bubble")
        newsCommentImage.tintColor = .gray
        newsCommentLabel.text = "\(newsCommentCount)"
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        addGestureRecognizer(recognizer)
    }
    
    @objc func onTap(_ sender: Any?) {
        print("News Comments indicator tapped")
    }
}


