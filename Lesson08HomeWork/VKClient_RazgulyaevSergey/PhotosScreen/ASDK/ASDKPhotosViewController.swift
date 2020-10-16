//
//  ASDKPhotosViewController.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 14.10.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class ASDKPhotosViewController: ASViewController<ASTableNode> {
    //MARK: - Base properties
    var name: String = ""
    var friendID: Int = 0
    
    var tableNode: ASTableNode {
        return node
    }
    var friendsPhotos = [PhotoItems]()
    
    //MARK: - Properties for Interaction with Network
    let networkService = NetworkService()
    
    init() {
        super.init(node: ASTableNode())
        self.tableNode.delegate = self
        self.tableNode.dataSource = self
        
        self.tableNode.allowsSelection = false
        self.tableNode.backgroundColor = .black
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("name = \(name)")
        print("friendID = \(friendID)")
        loadPhotosFromNetWork()
    }
}

//MARK: - Interaction with Network
extension ASDKPhotosViewController {
    func loadPhotosFromNetWork() {
        networkService.loadPhotos(token: Session.instance.token, ownerID: friendID, albumID: .profile, photoCount: 30) { [weak self] result in
            switch result {
            case let .success(photos):
                self?.friendsPhotos = photos
                print("friendsPhotos\n \(String(describing: self?.friendsPhotos))")
                self?.tableNode.reloadData()
            case let .failure(error):
                print(error)
            }
        }
    }
}

//MARK: - TableNode Data Source Methods
extension ASDKPhotosViewController: ASTableDataSource {
    
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1
    }

    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return friendsPhotos.count
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        guard friendsPhotos.count > indexPath.section else { return  ASCellNode() }
        return ASDKImageNode(resource: friendsPhotos[indexPath.row])
    }
}

/*
//MARK: - TableNode Data Source Methods
extension ASDKPhotosViewController: ASTableDataSource {
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return friendsPhotos.count
    }

    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        guard friendsPhotos.count > indexPath.section else { return { ASCellNode() } }
        let cellNodeBlock = { () -> ASCellNode in
            let node = ASDKImageNode(resource: self.friendsPhotos[indexPath.section])
            return node
        }
        return cellNodeBlock
//        ASDKImageNode(resource: friendsPhotos[indexPath.row])
    }
}
*/


//MARK: - TableNode Delegate Methods
extension ASDKPhotosViewController: ASTableDelegate {
//    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
//        true
//    }
}
