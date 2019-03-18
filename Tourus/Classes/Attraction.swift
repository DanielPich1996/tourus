//
//  Atraction.swift
//  Tourus
//
//  Created by admin on 12/01/2019.
//  Copyright © 2019 Tourus. All rights reserved.
//

import Foundation

class Attraction {
    let uid : String
    let atractionName : String
    //let categories = [String]()
    let email : String
    let phone : Float
    let discription : String?
    let openHours : String?
    
    init(_uid:String, _atractionName:String, _categories:[String], _email:String, _phone:Float, _discription:String? = nil, _openHours:String? = nil) {
        uid = _uid
        atractionName = _atractionName
        email = _email
        phone = _phone
        discription = _discription
        openHours = _openHours
        //categories = _categories
    }
    
    init(_uid:String, json:[String:Any]) {
        uid = json["uid"] as! String
        atractionName = json["atractionName"] as! String
        email = json["email"] as! String
        phone = json["phone"] as! Float
        discription = json["discription"] as? String
        openHours = json["openHours"] as? String
        //categories = ((json["categories"] as? [String]) ?? nil)!
    }
    
    func toJson() -> [String:Any] {
        var json = [String:Any]()
        
        json["uid"] = uid
        json["atractionName"] = atractionName
        json["email"] = email
        json["phone"] = phone
        json["discription"] = discription ?? ""
        json["openHours"] = openHours ?? ""
        
        return json
    }
}


