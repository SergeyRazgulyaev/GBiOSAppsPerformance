//
//  PhotoCell.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 09.07.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    @IBOutlet weak var photoCard: UIImageView!
    @IBOutlet weak var photoNumber: UILabel!
    @IBOutlet weak var photoDate: UILabel!
    @IBOutlet weak var heartView: HeartView!
    @IBOutlet weak var photosViewController: UIViewController!
    @IBOutlet weak var friendName: UILabel!
    var userID: Int?
    
    var interactiveAnimator: UIViewPropertyAnimator!
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        configure()
    }
    
    func configure() {
        photoCard.isUserInteractionEnabled = true
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        addGestureRecognizer(recognizer)
    }
    
    @objc func onTap(_ sender: Any?) {
        self.photosViewController.shouldPerformSegue(withIdentifier: "zoomPhotoSegue", sender: Any?.self)
        let vc = self.photosViewController.storyboard?.instantiateViewController(withIdentifier: "ZoomPhotoVC") as! ZoomPhotoViewController
        vc.friendZoomPhotoNumber = Int(photoNumber.text!)
        vc.friendID = userID
        vc.transitioningDelegate = self.photosViewController as? UIViewControllerTransitioningDelegate
        self.photosViewController.navigationController?.delegate = self.photosViewController as? UINavigationControllerDelegate
        self.photosViewController.navigationController?.pushViewController(vc, animated: true)    }
}
