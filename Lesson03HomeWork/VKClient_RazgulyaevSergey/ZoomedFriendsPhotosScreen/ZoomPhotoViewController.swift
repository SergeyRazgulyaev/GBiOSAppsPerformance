//
//  ZoomPhotoViewController.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 27.07.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import UIKit
import RealmSwift

class ZoomPhotoViewController: UIViewController {
    @IBOutlet private weak var zoomedFriendsPhotoImageView: UIImageView!
    @IBOutlet private weak var zoomedNextFriendPhotoImageView: UIImageView!
    
    //MARK: - Base properties
    var friendID: Int?
    var friendZoomPhotoNumber: Int?
    private var zoomPhotoIndex: Int?
    private var photoNumbersArray: [Int] = []
    private var previousImage: UIImage? = UIImage(systemName: "tortoise")
    private var shownImage: UIImage? = UIImage(systemName: "hare")
    private var nextImage: UIImage? = UIImage(systemName: "hare")
    
    //MARK: - Properties for Interaction with Network
    private let networkService = NetworkService()
    
    //MARK: - Properties for Interaction with Database
    private let realmManagerPhotos = RealmManager.instance
    private var oneFriendPhotosFromRealm: Results<PhotoItems>? {
        let oneFriendPhotosFromRealm: Results<PhotoItems>? = realmManagerPhotos?.getObjects().filter("ownerID = \(friendID ?? -1)")
        return oneFriendPhotosFromRealm
    }
    
    //MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        zoomedFriendsPhotoImageView.isUserInteractionEnabled = true
        zoomedNextFriendPhotoImageView.isUserInteractionEnabled = true
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeGesture(_:)))
        swipeRight.direction = .right
        zoomedFriendsPhotoImageView.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeGesture(_:)))
        swipeLeft.direction = .left
        zoomedFriendsPhotoImageView.addGestureRecognizer(swipeLeft)
        
        loadPhotosFromNetWork()
        calculationOfZoomPhotoIndex()
        showZoomPhotos()
    }
}

//MARK: - Interaction with Network
extension ZoomPhotoViewController {
    func loadPhotosFromNetWork() {
        guard friendID != nil else {
            zoomedFriendsPhotoImageView.image = UIImage(systemName: "tortoise")
            print("Oops!")
            return
        }
        networkService.loadPhotos(token: Session.instance.token, ownerID: friendID!, albumID: .profile, photoCount: 10) { [weak self] result in
            switch result {
            case let .success(photos):
                try? self?.realmManagerPhotos?.add(objects: photos)
            case let .failure(error):
                print(error)
            }
        }
    }
}

//MARK: - Preparation for Display Block
extension ZoomPhotoViewController {
    func calculationOfZoomPhotoIndex() {
        guard friendZoomPhotoNumber != nil else {
            friendZoomPhotoNumber = 1
            zoomPhotoIndex = 0
            return
        }
        zoomPhotoIndex = oneFriendPhotosFromRealm!.count - friendZoomPhotoNumber!
        //        print("zoomPhotoIndex \(String(describing: zoomPhotoIndex))")
    }
    
    func showZoomPhotos() {
        guard let zoomedFriendsPhotoURL = URL(string: oneFriendPhotosFromRealm![zoomPhotoIndex!].sizes.last!.url), let zoomedFriendsPhotoData = try? Data(contentsOf: zoomedFriendsPhotoURL) else { return }
        if zoomPhotoIndex! < (oneFriendPhotosFromRealm!.count - 1) && zoomPhotoIndex! >= 0 {
            guard let zoomedNextFriendsPhotoURL = URL(string: oneFriendPhotosFromRealm![zoomPhotoIndex! + 1].sizes.last!.url), let zoomedNextFriendsPhotoData = try? Data(contentsOf: zoomedNextFriendsPhotoURL) else { return }
            zoomedFriendsPhotoImageView.image = UIImage(data: zoomedFriendsPhotoData)
            zoomedNextFriendPhotoImageView.image = UIImage(data: zoomedNextFriendsPhotoData)
        }
        if zoomPhotoIndex! == (oneFriendPhotosFromRealm!.count - 1) {
            guard let zoomedNextFriendsPhotoURL = URL(string: oneFriendPhotosFromRealm![0].sizes.last!.url), let zoomedNextFriendsPhotoData = try? Data(contentsOf: zoomedNextFriendsPhotoURL) else { return }
            zoomedFriendsPhotoImageView.image = UIImage(data: zoomedFriendsPhotoData)
            zoomedNextFriendPhotoImageView.image = UIImage(data: zoomedNextFriendsPhotoData)
        }
        else { return }
    }
    
    func photoNumbersArrayCreator(photoCount: Int) {
        var tempArray: [Int] = []
        guard photoCount != 0 else {
            return
        }
        for i in 1...photoCount {
            tempArray.append(i)
        }
        photoNumbersArray = tempArray.sorted(by: {$1<$0})
    }
}

//MARK: - Swipe Gesture Recognizer
extension ZoomPhotoViewController {
    @objc func swipeGesture(_ sender: UISwipeGestureRecognizer?) {
        if let swipeGesture = sender {
            switch swipeGesture.direction {
            case .right:
                if zoomPhotoIndex! == 0 {
                    print("No elements to swipe")
                }
                if zoomPhotoIndex! > 0 && zoomPhotoIndex! < (oneFriendPhotosFromRealm!.count - 1)  {
                    guard let previousImageURL = URL(string: oneFriendPhotosFromRealm![zoomPhotoIndex!-1].sizes.last!.url), let previousImageData = try? Data(contentsOf: previousImageURL) else { return }
                    guard let shownImageURL = URL(string: oneFriendPhotosFromRealm![zoomPhotoIndex!].sizes.last!.url), let shownImageData = try? Data(contentsOf: shownImageURL) else { return }
                    previousImage = UIImage(data: previousImageData)
                    shownImage = UIImage(data: shownImageData)
                    print("Swipe right")
                    photosReverseAnimation()
                }
                if zoomPhotoIndex! == (oneFriendPhotosFromRealm!.count - 1) {
                    guard let previousImageURL = URL(string: oneFriendPhotosFromRealm![zoomPhotoIndex!-1].sizes.last!.url), let previousImageData = try? Data(contentsOf: previousImageURL) else { return }
                    guard let shownImageURL = URL(string: oneFriendPhotosFromRealm![zoomPhotoIndex!].sizes.last!.url), let shownImageData = try? Data(contentsOf: shownImageURL) else { return }
                    guard oneFriendPhotosFromRealm!.count > 1 else { return }
                    previousImage = UIImage(data: previousImageData)
                    shownImage = UIImage(data: shownImageData)
                    print("Swipe right")
                    photosReverseAnimation()
                }
            case .left:
                
                if zoomPhotoIndex! == 0 {
                    guard let nextImageURL = URL(string: oneFriendPhotosFromRealm![zoomPhotoIndex!+1].sizes.last!.url), let nextImageData = try? Data(contentsOf: nextImageURL) else { return }
                    guard let shownImageURL = URL(string: oneFriendPhotosFromRealm![zoomPhotoIndex!].sizes.last!.url), let shownImageData = try? Data(contentsOf: shownImageURL) else { return }
                    guard oneFriendPhotosFromRealm!.count > 1 else { return }
                    nextImage = UIImage(data: nextImageData)
                    shownImage = UIImage(data: shownImageData)
                    print("Swipe left")
                    photosAnimation()
                }
                if zoomPhotoIndex! > 0 && zoomPhotoIndex! < (oneFriendPhotosFromRealm!.count - 1)  {
                    guard let nextImageURL = URL(string: oneFriendPhotosFromRealm![zoomPhotoIndex!+1].sizes.last!.url), let nextImageData = try? Data(contentsOf: nextImageURL) else { return }
                    guard let shownImageURL = URL(string: oneFriendPhotosFromRealm![zoomPhotoIndex!].sizes.last!.url), let shownImageData = try? Data(contentsOf: shownImageURL) else { return }
                    nextImage = UIImage(data: nextImageData)
                    shownImage = UIImage(data: shownImageData)
                    print("Swipe left")
                    photosAnimation()
                }
                if zoomPhotoIndex! == oneFriendPhotosFromRealm!.count - 1 {
                    print("No elements to swipe")
                }
            default:
                break
            }
        }
    }
}

//MARK: - Animation Block
extension ZoomPhotoViewController {
    func photosAnimation() {
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            self.zoomPhotoIndex! += 1
        })
        
        zoomedNextFriendPhotoImageView.image = nextImage
        zoomedFriendsPhotoImageView.image = shownImage
        
        let animationTransformScale = CASpringAnimation(keyPath: "transform.scale")
        animationTransformScale.duration = 1
        animationTransformScale.fromValue = 1
        animationTransformScale.toValue = 0.9
        animationTransformScale.stiffness = 100
        animationTransformScale.mass = 0.3
        animationTransformScale.fillMode = CAMediaTimingFillMode.both
        animationTransformScale.isRemovedOnCompletion = false
        zoomedFriendsPhotoImageView.layer.add(animationTransformScale, forKey: nil)
        
        let animationTransform = CABasicAnimation(keyPath: "position.x")
        animationTransform.duration = 1
        animationTransform.fromValue = zoomedNextFriendPhotoImageView.frame.width * 2
        animationTransform.toValue = zoomedNextFriendPhotoImageView.frame.width / 2
        animationTransform.fillMode = CAMediaTimingFillMode.both
        animationTransform.isRemovedOnCompletion = false
        zoomedNextFriendPhotoImageView.layer.add(animationTransform, forKey: nil)
        
        CATransaction.commit()
    }
    
    func photosReverseAnimation() {
        zoomedNextFriendPhotoImageView.image = shownImage
        zoomedFriendsPhotoImageView.image = previousImage
        zoomPhotoIndex! -= 1
        
        let animationTransformScale = CASpringAnimation(keyPath: "transform.scale")
        animationTransformScale.duration = 1
        animationTransformScale.fromValue = 0.9
        animationTransformScale.toValue = 1
        animationTransformScale.stiffness = 100
        animationTransformScale.mass = 0.3
        animationTransformScale.fillMode = CAMediaTimingFillMode.both
        animationTransformScale.isRemovedOnCompletion = false
        zoomedFriendsPhotoImageView.layer.add(animationTransformScale, forKey: nil)
        
        let animationTransform = CABasicAnimation(keyPath: "position.x")
        animationTransform.duration = 1
        animationTransform.fromValue = zoomedNextFriendPhotoImageView.frame.width / 2
        animationTransform.toValue = zoomedNextFriendPhotoImageView.frame.width * 2
        animationTransform.fillMode = CAMediaTimingFillMode.both
        animationTransform.isRemovedOnCompletion = false
        zoomedNextFriendPhotoImageView.layer.add(animationTransform, forKey: nil)
        
    }
}
