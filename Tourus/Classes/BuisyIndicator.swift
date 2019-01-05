//
//  BuisyIndicator.swift
//  Tourus
//
//  Created by admin on 05/01/2019.
//  Copyright © 2019 Tourus. All rights reserved.
//

import UIKit

class BuisyIndicator: UIView {

    static let Instance = BuisyIndicator()

    var viewColor:UIColor = .black
    var setAlpha:CGFloat = 0.5
    var gifName:String = "loading"
    
    lazy var transparentView:UIView = {
        let transparentView = UIView(frame: UIScreen.main.bounds)
        transparentView.backgroundColor = viewColor.withAlphaComponent(setAlpha)
        transparentView.isUserInteractionEnabled = false
        return transparentView
    }()
    
    lazy var gifImage:UIImageView = {
        let gif = UIImage.gifImageWithName(gifName)

        let gifImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 240, height: 100))
        gifImage.contentMode = .scaleAspectFit
        gifImage.center = transparentView.center
        gifImage.isUserInteractionEnabled = false
        gifImage.image = gif
        
        return gifImage
    }()
    
    func showBuisyIndicator() {
        self.addSubview(transparentView)
        self.transparentView.addSubview(gifImage)
        self.transparentView.bringSubviewToFront(self.gifImage)
        UIApplication.shared.keyWindow?.addSubview(transparentView)
    }
    
    func hideBuisyIndicator() {
        self.transparentView.removeFromSuperview()
    }
}
