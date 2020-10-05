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
    @IBOutlet private weak var friendAvatar: FriendAvatar!

    func configureTitleLabel(titleLabelText: String) {
        titleLabel.text = titleLabelText
    }
    
    func configureFriendAvatarImage(friendAvatarImage: UIImage) {
        friendAvatarImageView.image = friendAvatarImage
    }
    
    func getTextFromTitleLabel() -> String {
        return titleLabel.text ?? ""
    }
    
    func getFriendAvatar() -> FriendAvatar {
        return friendAvatar
    }
    
    //MARK: - Action Block
    @IBAction func friendAvatarTap(_ sender: Any) {
        friendAvatar.avatarTapWithAnimation()
    }
}
