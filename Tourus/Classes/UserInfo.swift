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
    
    init(_uid:String, _displayName:String, _email:String, _profileImageUrl:String? = nil, _timestamp:Double = 0) {
        uid = _uid
        displayName = _displayName
        email = _email
        profileImageUrl = _profileImageUrl
        timestamp = _timestamp
    }
    
    init(_uid:String, json:[String:Any]) {
        uid = _uid
        displayName = json["displayName"] as! String
        email = json["email"] as! String
        profileImageUrl = json["profileImageUrl"] as? String
        
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
        
        return json
    }
}


