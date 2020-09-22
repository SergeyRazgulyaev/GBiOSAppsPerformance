//
//  FriendCell.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 09.07.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import UIKit

class FriendCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet weak var friendAvatar: FriendAvatar!
    @IBOutlet weak var friendAvatarImageView: UIImageView!
    
    @IBAction func friendAvatarTap(_ sender: Any) {
        friendAvatar.avatarTapWithAnimation()
    }
}
