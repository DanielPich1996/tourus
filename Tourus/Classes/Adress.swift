//
//  Adress.swift
//  Tourus
//
//  Created by admin on 12/01/2019.
//  Copyright © 2019 Tourus. All rights reserved.
//

import Foundation

class Adress {
    var country : String
    var city : String
    var building : Int
    
    init(_country:String, _city:String, _building:Int) {
        country = _country
        city = _city
        building = _building
    }
    
    init(json : [String:Any]) {
        country = json["country"] as! String
        city = json["city"] as! String
        building = json["building"] as! Int
    }
    
}
