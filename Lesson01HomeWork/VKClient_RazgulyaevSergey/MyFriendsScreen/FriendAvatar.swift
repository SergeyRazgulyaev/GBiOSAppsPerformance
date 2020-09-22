//
//  FriendAvatar.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 24.07.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import UIKit

class FriendAvatar: UIControl {
    @IBOutlet weak var friendAvatarImage: UIImageView!
    @IBOutlet weak var friendViewController: UIViewController!
    @IBOutlet weak var titleLable: UILabel!
    var userID: Int?
    
    private var filteredArray = [MyFriends]()
    var myFriendsArray: [MyFriends] = []
    
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
        
        friendAvatarImage.layer.cornerRadius = friendAvatarImage.bounds.width / 2
        friendAvatarImage.clipsToBounds = true
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        addGestureRecognizer(recognizer)
    }

    @objc func onTap(_ sender: Any?) {
        avatarTapWithAnimation()
    }
    
    func avatarTapWithAnimation() {
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            self.friendViewController.shouldPerformSegue(withIdentifier: "photosSegue", sender: Any?.self)
            let vc = self.friendViewController.storyboard?.instantiateViewController(withIdentifier: "FriendsPhotosVC") as! PhotosViewController
            vc.name = self.titleLable.text
            
            vc.friendID = self.userID!
            self.filterContentForName(self.titleLable.text!)
            self.accessibilityActivate()
            self.friendViewController.navigationController?.pushViewController(vc, animated: true)
        })
        
        let animation = CASpringAnimation(keyPath: "transform.scale")
        animation.fromValue = 0.9
        animation.toValue = 1
        animation.stiffness = 300
        animation.mass = 0.5
        animation.duration = 0.5
        animation.beginTime = CACurrentMediaTime()
        animation.fillMode = CAMediaTimingFillMode.backwards
        
        friendAvatarImage.layer.add(animation, forKey: nil)
        self.layer.add(animation, forKey: nil)
        
        CATransaction.commit()
    }
    
    func filterContentForName(_ searchText: String) {
        filteredArray = myFriendsArray.filter({(friend: MyFriends) -> Bool in
            return friend.friendName.lowercased().contains(searchText.lowercased())
        })
    }
}
