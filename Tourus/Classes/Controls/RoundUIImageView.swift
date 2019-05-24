//
//  RoundUIImageView.swift
//  Tourus
//
//  Created by admin on 24/05/2019.
//  Copyright © 2019 Tourus. All rights reserved.
//

import UIKit

@IBDesignable
class RoundUIImageView: UIImageView {

    @IBInspectable var borderColor: UIColor = UIColor.white {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 2.0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var clipControlToBounds: Bool = false {
        didSet {
            self.clipsToBounds = clipControlToBounds
        }
    }
}
