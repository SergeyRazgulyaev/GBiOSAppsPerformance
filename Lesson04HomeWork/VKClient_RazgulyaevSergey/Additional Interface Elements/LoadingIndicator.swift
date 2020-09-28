//
//  LoadingIndicator.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 22.07.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import UIKit

class LoadingIndicator: UIView {
    @IBOutlet private weak var loadingIndicatorImageView1: UIImageView!
    @IBOutlet private weak var loadingIndicatorImageView2: UIImageView!
    @IBOutlet private weak var loadingIndicatorImageView3: UIImageView!
    @IBOutlet private weak var loginViewController: UIViewController!
    @IBOutlet private weak var goButton:UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    func configure() {
        loadingIndicatorImageView1.image = UIImage(systemName: "")
        loadingIndicatorImageView2.image = UIImage(systemName: "")
        loadingIndicatorImageView3.image = UIImage(systemName: "")
        loadingIndicatorImageView1.alpha = 1.0
        loadingIndicatorImageView2.alpha = 1.0
        loadingIndicatorImageView3.alpha = 1.0
    }
    
    func startLoadingIndicatorHareAndTortoise() {
        configure()
        UIView.animate(withDuration: 1.0, animations: {
            self.loadingIndicatorImageView1.image = UIImage(systemName: "hare.fill")
            self.loadingIndicatorImageView1.alpha = 0.0
        }, completion: { [weak self] _ in
            UIView.animate(withDuration: 1.0, animations:{
                self?.loadingIndicatorImageView2.image = UIImage(systemName: "hare.fill")
                self?.loadingIndicatorImageView2.alpha = 0.0
            }, completion: { [weak self] _ in
                UIView.animate(withDuration: 1.0, animations:{
                    self?.loadingIndicatorImageView3.image = UIImage(systemName: "hare.fill")
                    self?.loadingIndicatorImageView3.alpha = 0.0
                }, completion: { [weak self] _ in
                    self?.startLoadingIndicatorTurtle()
                })
            })
        })
    }
    
    func startLoadingIndicatorTurtle() {
        configure()
        UIView.animate(withDuration: 1.0, animations: {
            self.loadingIndicatorImageView1.image = UIImage(systemName: "tortoise.fill")
            self.loadingIndicatorImageView1.alpha = 0.0
        }, completion: { [weak self] _ in
            UIView.animate(withDuration: 1.0, animations:{
                self?.loadingIndicatorImageView2.image = UIImage(systemName: "tortoise.fill")
                self?.loadingIndicatorImageView2.alpha = 0.0
            }, completion: { [weak self] _ in
                UIView.animate(withDuration: 1.0, animations:{
                    self?.loadingIndicatorImageView3.image = UIImage(systemName: "tortoise.fill")
                    self?.loadingIndicatorImageView3.alpha = 0.0
//                }, completion: { [weak self] _ in
                    //                    self.loginViewController.shouldPerformSegue(withIdentifier: "loginSegue", sender: Any?.self)
                    //                    let vc = self.loginViewController.storyboard?.instantiateViewController(withIdentifier: "AfterLoginVC")
                    //                    self.loginViewController.present(vc!, animated: true, completion: nil)
                })
            })
        })
        
    }
}
