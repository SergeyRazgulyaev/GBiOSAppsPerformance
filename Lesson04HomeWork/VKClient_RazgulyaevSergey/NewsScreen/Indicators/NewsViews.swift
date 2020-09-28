//
//  NewsViews.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 21.07.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import UIKit

class NewsViews: UIView {
    @IBOutlet private weak var newsViewsLabel: UILabel!
    
    private let newsViewsImage = UIImageView()
    private var image = UIImage()
    private var newsViewsCount: Int = Int.random(in: 0...1000)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
        addSubview(newsViewsImage)
        configureGestureRecognizer()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        configure()
    }
    
    func configure() {
        newsViewsImage.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        newsViewsImage.contentMode = .scaleAspectFit
        newsViewsImage.image = UIImage(systemName: "eye")
        newsViewsImage.tintColor = .gray
        newsViewsLabel.text = "\(newsViewsCount)"
    }
    
    func configureGestureRecognizer() {
        let newsViewsTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        addGestureRecognizer(newsViewsTapRecognizer)
    }
    
    @objc func onTap(_ sender: Any?) {
        print("News Views indicator tapped")
    }
    
    func configureNewsViewsLabelText(newsViewsLabelText: String) {
        newsViewsLabel.text = newsViewsLabelText
    }
}

