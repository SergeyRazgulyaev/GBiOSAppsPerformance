//
//  AvailableGroup.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 10.07.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import UIKit

struct AvailableGroup {
    let availableGroupName: String
    var availableGroupAvatar: UIImage?
    init(availableGroupName: String, availableGroupAvatar: UIImage?) {
        self.availableGroupName = availableGroupName
        self.availableGroupAvatar = availableGroupAvatar
    }
}

var availableGroups: [AvailableGroup] = [
    AvailableGroup(availableGroupName: "Home design", availableGroupAvatar: UIImage(named: "homeDesign")),
    AvailableGroup(availableGroupName: "Learning English", availableGroupAvatar: UIImage(named: "learningEnglish")),
    AvailableGroup(availableGroupName: "Blizzard Fans", availableGroupAvatar: UIImage(named: "blizzardFans")),
    AvailableGroup(availableGroupName: "Guinness world records", availableGroupAvatar: UIImage(named: "guinnessWorldRecords")),
    AvailableGroup(availableGroupName: "Technology news", availableGroupAvatar: UIImage(named: "technologyNews")),
    AvailableGroup(availableGroupName: "History", availableGroupAvatar: UIImage(named: "history"))
]
