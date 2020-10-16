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

    //MARK: - Configuration Methods
    func configureTitleLabel(titleLabelText: String) {
        titleLabel.text = titleLabelText
    }
    
    func configureFriendAvatarImage(friendAvatarImage: UIImage) {
        friendAvatarImageView.image = friendAvatarImage
    }
    
    //MARK: - Access Methods
    func getTextFromTitleLabel() -> String {
        return titleLabel.text ?? ""
    }
    
    func getFriendAvatar() -> FriendAvatar {
        return friendAvatar
    }
    
    //MARK: - IBActions
    @IBAction func friendAvatarTap(_ sender: Any) {
        friendAvatar.avatarTapWithAnimation()
    }
}
