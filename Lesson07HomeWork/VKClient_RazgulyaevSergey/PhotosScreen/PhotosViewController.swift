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
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var friendsNameLabel: UILabel!
    
    //MARK: - Base properties
    var name: String?
    var friendID: Int?
    private var photosNumbersCount: Int = 1
    private var timeSortedArray: [String] = []
    private var photoNumbersArray: [Int] = []
    private let interactiveTransition = InteractiveTransition()
    private var dateTextCache: [IndexPath : String] = [:]
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = DateFormatter.Style.long
        return df
    }()
    
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
        configurePhotosViewController()
        createNotification()
        loadPhotosFromNetWorkIfNeeded()
    }
    
    //MARK: - Configuration Methods
    func configurePhotosViewController() {
        collectionView.dataSource = self
        collectionView.delegate = self
        friendsNameLabel.text = name
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: 200, height: 230)
        }
    }
    
    //MARK: - Deinit photosNotificationToken
    deinit {
        photosNotificationToken?.invalidate()
    }
}

//MARK: - Interaction with Network
extension PhotosViewController {
    func loadPhotosFromNetWorkIfNeeded() {
        if let photos = oneFriendPhotosFromRealm, photos.isEmpty {
//            print("loadPhotosFromNetWork activated")
            loadPhotosFromNetWork()
        } else {
//            print("loadPhotosFromNetWork is not active")
        }
    }
    
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
//MARK: - Interaction with Realm Database
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

//MARK: - Collection Data Source Methods
extension PhotosViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        oneFriendPhotosFromRealm!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        configureCell(indexPath: indexPath)
    }

    func configureCell(indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as? PhotoCell else { return UICollectionViewCell() }
        guard let url = URL(string: ((oneFriendPhotosFromRealm?[indexPath.row])?.sizes.last?.url)!), let data = try? Data(contentsOf: url) else { return cell }
        let photoNumber = String("Photo \(oneFriendPhotosFromRealm!.count - indexPath.row)")
        let likeCount = String(oneFriendPhotosFromRealm![indexPath.row].likes!.count)
        cell.configureCellUI(photoCardImage: (UIImage(data: data) ?? UIImage(systemName: "tortoise.fill"))!, photoNumberLabelText: photoNumber, photoDateLabelText: getCellDateText(forIndexPath: indexPath, andTimeToTranslate: Double(oneFriendPhotosFromRealm![indexPath.row].date)))
        cell.getHeartView().configureheartLabel(heartLabelNumber: likeCount)
        cell.userID = friendID
        return cell
    }
}

//MARK: - Collection Delegate Methods
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

//MARK: - Method for translating and caching Dates
extension PhotosViewController {
    func getCellDateText(forIndexPath indexPath: IndexPath, andTimeToTranslate timeToTranslate: Double) -> String {
        if let stringDate = dateTextCache[indexPath] {
            print("The Date of cell \(indexPath.row) is already in the Cache")
            return stringDate
        } else {
            let date = Date(timeIntervalSince1970: timeToTranslate)
            let localDate = dateFormatter.string(from: date)
            dateTextCache[indexPath] = localDate
            print("The Date of cell \(indexPath.row) is written to the Сache")
            return localDate
        }
    }
}

//MARK: - Alert 
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
