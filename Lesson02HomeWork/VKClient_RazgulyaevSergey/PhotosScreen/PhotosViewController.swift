//
//  PhotosViewController.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 09.07.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import UIKit
import RealmSwift

class PhotosViewController: UIViewController {
    @IBOutlet private weak var collectionView: UICollectionView!{
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
        }
    }
    @IBOutlet private weak var friendsNameLabel: UILabel!
    
    //MARK: - Base properties
    var name: String?
    var friendID: Int?
    private var photosNumbersCount: Int = 1
    private var timeSortedArray: [String] = []
    private var photoNumbersArray: [Int] = []
    
    let interactiveTransition = InteractiveTransition()
    
    //MARK: - Properties for Interaction with Network
    private let networkService = NetworkService()
    
    //MARK: - Properties for Interaction with Database
    private var photosNotificationToken: NotificationToken?
    private let realmManagerPhotos = RealmManager.instance
    
    private var allPhotosFromRealm: Results<PhotoItems>? {
        let photosFromRealm: Results<PhotoItems>? = realmManagerPhotos?.getObjects()
        return photosFromRealm
    }
    
    private var oneFriendPhotosFromRealm: Results<PhotoItems>? {
        let oneFriendPhotosFromRealm: Results<PhotoItems>? = realmManagerPhotos?.getObjects().filter("ownerID = \(friendID ?? -1)")
        return oneFriendPhotosFromRealm
    }
    
    //MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        friendsNameLabel.text = name
        
        createNotification()
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: 200, height: 230)
        }
        
        //MARK: - Function loadPhotosFromNetWork activation
        if let photos = oneFriendPhotosFromRealm, photos.isEmpty {
            print("loadPhotosFromNetWork activated")
            loadPhotosFromNetWork()
        } else {
            print("loadPhotosFromNetWork is not active")
        }
    }
    
    //MARK: - Deinit photosNotificationToken
    deinit {
        photosNotificationToken?.invalidate()
    }
}

//MARK: - Interaction with Network
extension PhotosViewController {
    func loadPhotosFromNetWork() {
        networkService.loadPhotos(token: Session.instance.token, ownerID: friendID!, albumID: .profile, photoCount: 10) { [weak self] result in
            switch result {
            case let .success(photos):
                try? self?.realmManagerPhotos?.add(objects: photos)
                self?.collectionView.reloadData()
            case let .failure(error):
                print(error)
            }
        }
    }
}

//MARK: - CollectionView Customization
extension PhotosViewController: UICollectionViewDataSource {
    
    //MARK: - Number Of Items In Section
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        oneFriendPhotosFromRealm!.count
    }
    
    //MARK: - Cell For Item At IndexPath
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as? PhotoCell else {fatalError()}
        guard let url = URL(string: ((oneFriendPhotosFromRealm?[indexPath.row])?.sizes.last?.url)!), let data = try? Data(contentsOf: url) else { return cell }
        cell.photoNumberLabel.text = String(oneFriendPhotosFromRealm!.count)
        cell.photoCardImageView.image = UIImage(data: data)
        cell.photoDateLabel.text = dateTranslator(timeToTranslate: oneFriendPhotosFromRealm![indexPath.row].date)
        cell.heartView.heartLabel.text = String(oneFriendPhotosFromRealm![indexPath.row].likes!.count)
        cell.photoNumberLabel.text = String("\(oneFriendPhotosFromRealm!.count - indexPath.row)")
        cell.userID = friendID
        return cell
    }
}
//MARK: - Did Select Item At IndexPath
extension PhotosViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //        print(indexPath)
    }
}

//MARK: - Animation of View Controller Transitioning
extension PhotosViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PushAnimator()
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PopAnimator()
    }
}

extension PhotosViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .pop {
            if navigationController.viewControllers.first != toVC {
                interactiveTransition.viewController = toVC
                return PopAnimator()
            }
            return nil
        } else {
            if navigationController.viewControllers.first != fromVC {
                interactiveTransition.viewController = toVC
                return PushAnimator()
            }
            return nil
        }
    }
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveTransition.hasStarted ? interactiveTransition : nil
    }
}

//MARK: - Date Translation Function
extension PhotosViewController {
    func dateTranslator(timeToTranslate: Int) -> String {
        var date: Date?
        date = Date(timeIntervalSince1970: Double(timeToTranslate))
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeZone = .current
        let localDate = dateFormatter.string(from: date!)
        return localDate
    }
}

//MARK: - Alert Block
extension PhotosViewController {
    private func showAlert(title: String? = nil,
                           message: String? = nil,
                           handler: ((UIAlertAction) -> ())? = nil,
                           completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: handler)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: completion)
    }
}

//MARK: - Function for observing filteredGroups changes
extension PhotosViewController {
    private func createNotification() {
        photosNotificationToken = oneFriendPhotosFromRealm?.observe { [weak self] change in
            switch change {
            case let . initial(oneFriendPhotosFromRealm):
                print("Initialized \(oneFriendPhotosFromRealm.count)")
                
            case let .update(oneFriendPhotosFromRealm, deletions: deletions, insertions: insertions, modifications: modifications):
                print("""
                    New count: \(oneFriendPhotosFromRealm.count)
                    Deletions: \(deletions)
                    Insertions: \(insertions)
                    Modifications: \(modifications)
                    """)
                self?.collectionView.reloadData()
                
            case let .error(error):
                self?.showAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }
}

