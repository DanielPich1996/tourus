//
//  Category.swift
//  Tourus
//
//  Created by admin on 13/01/2019.
//  Copyright © 2019 Tourus. All rights reserved.
//

import Foundation

class Category{
    let mainCategory : String
    var subCategories = [String]()
    
    init(_mainCategory : String, json : [String:Any]) {
        mainCategory = _mainCategory
        
        for (subCategory, temp) in json {
            self.subCategories.append(subCategory)
        }
    }
    
    init(_mainCategory : String, _subCategories : [String]) {
        mainCategory = _mainCategory
        subCategories = _subCategories
    }
    
    func toJson() -> [String:Any] {
        var json = [String:Any]()
        
        for (subCategory) in subCategories {
            json[subCategory] = ""
        }
        
        return json
    }
}
