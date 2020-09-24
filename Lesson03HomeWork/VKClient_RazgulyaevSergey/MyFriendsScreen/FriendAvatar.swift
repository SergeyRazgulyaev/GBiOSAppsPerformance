//
//  FriendAvatar.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 24.07.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import UIKit

class FriendAvatar: UIControl {
    @IBOutlet private weak var friendAvatarImageView: UIImageView!
    @IBOutlet private weak var friendViewController: UIViewController!
    @IBOutlet private weak var titleLable: UILabel!
    
    private var userID: Int?
    private var filteredArray = [MyFriends]()
    private var myFriendsArray: [MyFriends] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        configure()
    }
    
    func configure() {
        layer.cornerRadius = bounds.width / 2
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 5
        layer.shadowOpacity = 1
        layer.shadowOffset = .zero
        layer.shadowPath = UIBezierPath(ovalIn: bounds).cgPath
        
        friendAvatarImageView.layer.cornerRadius = friendAvatarImageView.bounds.width / 2
        friendAvatarImageView.clipsToBounds = true
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        addGestureRecognizer(recognizer)
    }
    
    @objc func onTap(_ sender: Any?) {
        avatarTapWithAnimation()
    }
    
    func configureUserID(userID: Int) {
        self.userID = userID
    }
    
    func getUserID() -> Int {
        return userID ?? 0
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
        
        friendAvatarImageView.layer.add(animation, forKey: nil)
        self.layer.add(animation, forKey: nil)
        
        CATransaction.commit()
    }
    
    func filterContentForName(_ searchText: String) {
        filteredArray = myFriendsArray.filter({(friend: MyFriends) -> Bool in
            return friend.friendName.lowercased().contains(searchText.lowercased())
        })
    }
}
