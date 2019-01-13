//
//  UserInfo.swift
//  Tourus
//
//  Created by admin on 03/01/2019.
//  Copyright © 2019 Tourus. All rights reserved.
//

import Foundation
import Firebase

class UserInfo {
    let uid:String
    let displayName:String
    let email:String
    var profileImageUrl:String?
    var timestamp:Double
    var phonNumber : Float?
    var birthYear : Int?
    var city : String?
    var country :String?
    var trips  = [String]()
    var categories = [String]()
    
    init(_uid:String, _displayName:String, _email:String, _profileImageUrl:String? = nil, _timestamp:Double = 0, _phonNumber:Float? = nil, _birthYear:Int? = nil, _country:String? = nil, _city:String? = nil) {
        uid = _uid
        displayName = _displayName
        email = _email
        profileImageUrl = _profileImageUrl
        timestamp = _timestamp
        phonNumber = _phonNumber
        birthYear = _birthYear
        country = _country
        city = _city
    }
    
    init(_uid:String, json:[String:Any]) {
        uid = _uid
        displayName = json["displayName"] as! String
        email = json["email"] as! String
        profileImageUrl = json["profileImageUrl"] as? String
        phonNumber = json["phonNumber"] as? Float
        birthYear = json["birthYear"] as? Int
        country = json["country"] as? String
        city = json["city"] as? String
        
        
        let date = json["lastUpdate"] as! Double?
        if(date != nil) {
            timestamp = date!
        }
        else {
            timestamp = 0
        }
    }
    
    func toJson() -> [String:Any] {
        var json = [String:Any]()
        
        json["displayName"] = displayName
        json["email"] = email
        json["profileImageUrl"] = profileImageUrl ?? ""
        json["lastUpdate"] = ServerValue.timestamp()
        json["phonNumber"] = phonNumber ?? 0
        json["birthYear"] = birthYear ?? 0
        json["country"] = country ?? ""
        json["city"] = city ?? ""
        
        return json
    }
}


