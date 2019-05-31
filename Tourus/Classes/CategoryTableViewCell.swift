//
//  CategoryTableViewCell.swift
//  Tourus
//
//  Created by admin on 28/05/2019.
//  Copyright © 2019 Tourus. All rights reserved.
//

import Foundation
import UIKit


class CategoryTableViewCell : UITableViewCell {

    @IBOutlet var categoryLabel: UILabel!

    var isChecked = false
    var category = ""
    
    public func setCellData(_ category:String, _ isChecked:Bool) {
        
       self.isChecked = isChecked
        self.category = category
        categoryLabel.text = category
        
        if self.isChecked {
            accessoryType = UITableViewCell.AccessoryType.checkmark
        } else {
             accessoryType = UITableViewCell.AccessoryType.none
        }
    }
}
