//
//  ASDKImageNode.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 14.10.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class ASDKImageNode: ASCellNode {
    private let photoImageNode = ASNetworkImageNode()
    private let resource: PhotoItems
    private var aspectRatio: CGFloat {
        guard resource.sizes.last != nil else { return 1 }
        return resource.sizes.last!.width != 0 ? CGFloat(resource.sizes.last!.height) / CGFloat(resource.sizes.last!.width) : 1
    }
    
    init(resource: PhotoItems) {
        self.resource = resource
        
        super.init()
        setupSubnodes()
    }
    
    private func setupSubnodes() {
        photoImageNode.url = URL(string: resource.sizes.last!.url)
        photoImageNode.contentMode = .scaleAspectFit
        photoImageNode.shouldRenderProgressImages = true
        
        addSubnode(photoImageNode)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let width = constrainedSize.max.width
        photoImageNode.style.preferredSize = CGSize(width: width, height: width * aspectRatio + 20)
        return ASWrapperLayoutSpec(layoutElement: photoImageNode)
    }
}
