//
//  Consts.swift
//  Tripit
//
//  Created by Raz Vaknin on 29 Kislev 5779.
//  Copyright © 5779 razop. All rights reserved.
//

import Foundation
import UIKit

struct consts{
    struct names {
        static let userInfoTableName : String = "Users"
        static let interactionsTableName : String = "Interactions"
        static let imagesFolderName : String = "ImagesStorage"
        static let profileImagesFolderName : String = "ProfileImagesStorage"
        static let attractionsTableName : String = "Attractions"
        static let categoriesTableName : String = "Categories"
    }
    
    struct text {
        static let lineBreak:String = "\n"
    }
    
    struct general {
        static func convertTimestampToStringDate(_ serverTimestamp: Double, _ format:String = "dd/MM/yyyy HH:mm") -> String {
            let x = serverTimestamp / 1000
            let date = NSDate(timeIntervalSince1970: x)
            let formatter = DateFormatter()
            formatter.dateFormat = format
            
            return formatter.string(from: date as Date)
        }
        
        static func getCancelAlertController(title:String, messgae:String, buttonText:String = "Dismiss") -> UIAlertController
        {
            let alertController = UIAlertController(title: title, message: messgae, preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: buttonText, style: UIAlertAction.Style.cancel, handler: nil))
            
            return alertController
        }
    }
}
