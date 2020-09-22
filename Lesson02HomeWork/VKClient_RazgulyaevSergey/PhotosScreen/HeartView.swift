//
//  HeartView.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 14.07.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import UIKit

class HeartView: UIControl {
    @IBOutlet weak var heartLabel: UILabel!
    
    let heartImageView = UIImageView()
    var image = UIImage()
    var heartCount: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        configure()
    }
    
    func configure() {
        heartImageView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        heartImageView.contentMode = .scaleAspectFit
        addSubview(heartImageView)
        heartImageView.image = UIImage(named: "HeartNo")
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        addGestureRecognizer(recognizer)
    }
    
    @objc func onTap(_ sender: Any?) {
        if heartImageView.image == UIImage(named: "HeartNo") {
            heartImageView.image = UIImage(named: "HeartYes")
            heartCount = Int(heartLabel.text!)!
            heartCount += 1
            UIView.transition(with: heartLabel, duration: 0.2, options: .transitionFlipFromRight, animations: {self.heartLabel.text = String(self.heartCount)})
            setNeedsDisplay()
        } else {
            heartImageView.image = UIImage(named: "HeartNo")
            heartCount = Int(heartLabel.text!)!
            heartCount -= 1
            UIView.transition(with: heartLabel, duration: 0.2, options: .transitionFlipFromLeft, animations: {self.heartLabel.text = String(self.heartCount)})
            setNeedsDisplay()
        }
    }
}
