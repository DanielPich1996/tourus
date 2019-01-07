//
//  InteractionButton.swift
//  Tourus
//
//  Created by admin on 07/01/2019.
//  Copyright © 2019 Tourus. All rights reserved.
//

import Foundation
import UIKit

class UIOptionButton: UIButton {
    private static let fontSize:CGFloat = 20
    private static let background:UIColor = .clear
    

    required init(option:Interaction.Option, tag:Int? = nil) {
        super.init(frame: .zero)
        
        setData(title: option.text, type: option.type, tag: tag)
    }
    
    required init(title:String, type:OptionType, tag:Int? = nil) {
        super.init(frame: .zero)
        setData(title: title, type: type, tag: tag)
    }
    
    private func setData(title:String, type:OptionType, tag:Int? = nil) {
        self.setTitle(title, for: UIControl.State.normal)
        //self.titleLabel?.font =  UIFont(name: "Trebuchet MS", size: 22)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .semibold)

        let titleSize = (title as NSString).size(withAttributes: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: UIOptionButton.fontSize + 1)])
        
        self.frame.size.height = titleSize.height * 2
        self.frame.size.width = titleSize.width
        self.tintColor = UIColor.white
        self.backgroundColor = UIOptionButton.background
        self.setTitleColor(type.color, for: UIControl.State.normal)
        self.setTitleColor(type.lightColor, for: UIControl.State.highlighted)
        self.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping;
        self.titleLabel?.textAlignment = NSTextAlignment.center
        self.contentMode = UIView.ContentMode.scaleToFill

        if(tag != nil) {
            self.tag = tag!
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
