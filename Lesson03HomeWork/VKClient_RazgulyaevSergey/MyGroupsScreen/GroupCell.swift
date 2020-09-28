//
//  GroupCell.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 09.07.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import UIKit

class GroupCell: UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var groupAvatarContainerView: UIView!
    @IBOutlet private weak var groupAvatarImageView: UIImageView!
    
    func configure(titleLabelText: String, groupAvatarImage: UIImage) {
        self.titleLabel.text = titleLabelText
        self.groupAvatarImageView.image = groupAvatarImage
    }
}
