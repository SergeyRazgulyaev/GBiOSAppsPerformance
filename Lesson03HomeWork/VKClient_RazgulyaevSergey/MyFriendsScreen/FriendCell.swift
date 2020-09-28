//
//  FriendCell.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 09.07.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import UIKit

class FriendCell: UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var friendAvatarImageView: UIImageView!
    @IBOutlet weak var friendAvatar: FriendAvatar!

    func configureTitleLabel(titleLabelText: String) {
        self.titleLabel.text = titleLabelText
    }
    
    func configureFriendAvatarImage(friendAvatarImage: UIImage) {
        self.friendAvatarImageView.image = friendAvatarImage
    }
    
    func getTextFromTitleLabel() -> String {
        return titleLabel.text ?? ""
    }
    
    @IBAction func friendAvatarTap(_ sender: Any) {
        friendAvatar.avatarTapWithAnimation()
    }
}
