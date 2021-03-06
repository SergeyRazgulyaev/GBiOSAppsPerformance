//
//  NewsViews.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 21.07.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import UIKit

class NewsViews: UIView {
    @IBOutlet weak var newsViewsLabel: UILabel!
    
    let newsViewsImage = UIImageView()
    var image = UIImage()
    var newsViewsCount: Int = Int.random(in: 0...1000)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        configure()
    }
    
    func configure() {
        newsViewsImage.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        newsViewsImage.contentMode = .scaleAspectFit
        addSubview(newsViewsImage)
        newsViewsImage.image = UIImage(systemName: "eye")
        newsViewsImage.tintColor = .gray
        newsViewsLabel.text = "\(newsViewsCount)"
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        addGestureRecognizer(recognizer)
    }
    
    @objc func onTap(_ sender: Any?) {
        print("News Views indicator tapped")
    }
}

