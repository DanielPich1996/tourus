//
//  Consts.swift
//  Tripit
//
//  Created by Raz Vaknin on 29 Kislev 5779.
//  Copyright © 5779 razop. All rights reserved.
//

import Foundation
import UIKit

struct consts {
    struct names {
        static let userInfoTableName : String = "Users"
        static let interactionsTableName : String = "Interactions"
        static let interactionHistoryTableName : String = "InteractionHistory"
        static let optionsTableName : String = "Options"
        static let imagesFolderName : String = "ImagesStorage"
        static let profileImagesFolderName : String = "ProfileImagesStorage"
        static let attractionsTableName : String = "Attractions"
        static let categoriesTableName : String = "Categories"
    }
    
    struct googleMaps {
        static let applicationLink : String = "comgooglemaps://"
        static let browserLink : String = "https://www.google.co.in/maps/dir/"
    }
    
    struct map {
         static let maxFarFromRouteInMeters:Int = 60
         static let destinationPinIdentifier:String = "destinationPin"
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
    
    struct graph {
        static let maxGraphPoints = 10
        static let maxDegree = 360
        static let cornerRadiusSize = CGSize(width: 8.0, height: 8.0)
        static let margin: CGFloat = 25.0
        static let topBorder: CGFloat = 35.0
        static let bottomBorder: CGFloat = 25
        static let colorAlpha: CGFloat = 0.3
        static let circleDiameter: CGFloat = 10.0
        static let maxPopWidth: Int = 200
        static let dismissAfterSec: Int = 30
    }
}
