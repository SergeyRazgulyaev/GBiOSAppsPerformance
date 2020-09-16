//
//  LoadingIndicator.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 22.07.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import UIKit

class LoadingIndicator: UIView {
    @IBOutlet weak var loadingIndicatorImage1: UIImageView!
    @IBOutlet weak var loadingIndicatorImage2: UIImageView!
    @IBOutlet weak var loadingIndicatorImage3: UIImageView!
    @IBOutlet weak var loginViewController: UIViewController!
    @IBOutlet weak var goButton:UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    func configure() {
        loadingIndicatorImage1.image = UIImage(systemName: "")
        loadingIndicatorImage2.image = UIImage(systemName: "")
        loadingIndicatorImage3.image = UIImage(systemName: "")
        loadingIndicatorImage1.alpha = 1.0
        loadingIndicatorImage2.alpha = 1.0
        loadingIndicatorImage3.alpha = 1.0
    }
    
    func startLoadingIndicatorHareAndTortoise() {
        configure()
        UIView.animate(withDuration: 1.0, animations: {
            self.loadingIndicatorImage1.image = UIImage(systemName: "hare.fill")
            self.loadingIndicatorImage1.alpha = 0.0
        }, completion: { _ in
            UIView.animate(withDuration: 1.0, animations:{
                self.loadingIndicatorImage2.image = UIImage(systemName: "hare.fill")
                self.loadingIndicatorImage2.alpha = 0.0
            }, completion: { _ in
                UIView.animate(withDuration: 1.0, animations:{
                    self.loadingIndicatorImage3.image = UIImage(systemName: "hare.fill")
                    self.loadingIndicatorImage3.alpha = 0.0
                }, completion: { _ in
                    self.startLoadingIndicatorTurtle()
                })
            })
        })
    }
    
    func startLoadingIndicatorTurtle() {
        configure()
        UIView.animate(withDuration: 1.0, animations: {
            self.loadingIndicatorImage1.image = UIImage(systemName: "tortoise.fill")
            self.loadingIndicatorImage1.alpha = 0.0
        }, completion: { _ in
            UIView.animate(withDuration: 1.0, animations:{
                self.loadingIndicatorImage2.image = UIImage(systemName: "tortoise.fill")
                self.loadingIndicatorImage2.alpha = 0.0
            }, completion: { _ in
                UIView.animate(withDuration: 1.0, animations:{
                    self.loadingIndicatorImage3.image = UIImage(systemName: "tortoise.fill")
                    self.loadingIndicatorImage3.alpha = 0.0
                }, completion: { _ in
//                    self.loginViewController.shouldPerformSegue(withIdentifier: "loginSegue", sender: Any?.self)
//                    let vc = self.loginViewController.storyboard?.instantiateViewController(withIdentifier: "AfterLoginVC")
//                    self.loginViewController.present(vc!, animated: true, completion: nil)
                })
            })
        })
        
    }
}
