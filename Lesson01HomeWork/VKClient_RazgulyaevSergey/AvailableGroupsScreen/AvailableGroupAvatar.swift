//
//  AvailableGroupAvatar.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 24.07.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import UIKit

class AvailableGroupAvatar: UIControl {
    @IBOutlet weak var availableGroupAvatarImage: UIImageView!
    
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
        
        
        availableGroupAvatarImage.layer.cornerRadius = availableGroupAvatarImage.bounds.width / 2
        availableGroupAvatarImage.clipsToBounds = true
        
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
        
        availableGroupAvatarImage.layer.add(animation, forKey: nil)
        self.layer.add(animation, forKey: nil)
    }
}
