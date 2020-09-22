//
//  GroupAvatar.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 24.07.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import UIKit

class GroupAvatar: UIControl {
    @IBOutlet weak var groupAvatarImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        configure()
    }
    
    func configure() {
        self.layer.cornerRadius = self.bounds.width / 2
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = .zero
        self.layer.shadowPath = UIBezierPath(ovalIn: self.bounds).cgPath
        
        
        groupAvatarImage.layer.cornerRadius = groupAvatarImage.bounds.width / 2
        groupAvatarImage.clipsToBounds = true
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        addGestureRecognizer(recognizer)
    }
    
    @objc func onTap(_ sender: Any?) {
        avatarTapAnimation()
    }
    
    func avatarTapAnimation() {
        let animation = CASpringAnimation(keyPath: "transform.scale")
        animation.fromValue = 0.9
        animation.toValue = 1
        animation.stiffness = 300
        animation.mass = 0.5
        animation.duration = 0.5
        animation.beginTime = CACurrentMediaTime()
        animation.fillMode = CAMediaTimingFillMode.backwards
        
        groupAvatarImage.layer.add(animation, forKey: nil)
        self.layer.add(animation, forKey: nil)
    }
}
