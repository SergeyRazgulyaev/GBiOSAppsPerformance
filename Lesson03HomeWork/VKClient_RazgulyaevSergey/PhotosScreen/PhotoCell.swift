//
//  PhotoCell.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 09.07.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    @IBOutlet private weak var photosViewController: UIViewController!
    @IBOutlet private weak var photoCardImageView: UIImageView!
    @IBOutlet private weak var photoNumberLabel: UILabel!
    @IBOutlet private weak var photoDateLabel: UILabel!
    @IBOutlet private weak var friendNameLabel: UILabel!
    @IBOutlet weak var heartView: HeartView!
    var userID: Int?
    
    var interactiveAnimator: UIViewPropertyAnimator!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        configure()
    }
    
    func configure() {
        photoCardImageView.isUserInteractionEnabled = true
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        addGestureRecognizer(recognizer)
    }

    @objc func onTap(_ sender: Any?) {
        self.photosViewController.shouldPerformSegue(withIdentifier: "zoomPhotoSegue", sender: Any?.self)
        let vc = self.photosViewController.storyboard?.instantiateViewController(withIdentifier: "ZoomPhotoVC") as! ZoomPhotoViewController
        vc.friendZoomPhotoNumber = Int(photoNumberLabel.text!)
        vc.friendID = userID
        vc.transitioningDelegate = self.photosViewController as? UIViewControllerTransitioningDelegate
        self.photosViewController.navigationController?.delegate = self.photosViewController as? UINavigationControllerDelegate
        self.photosViewController.navigationController?.pushViewController(vc, animated: true)
    }
    
    func configureCellUI(photoCardImage: UIImage, photoNumberLabelText: String, photoDateLabel: String) {
        self.photoCardImageView.image = photoCardImage
        self.photoNumberLabel.text = photoNumberLabelText
        self.photoDateLabel.text = photoDateLabel
    }
}
