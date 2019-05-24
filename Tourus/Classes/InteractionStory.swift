//
//  InteractionStory.swift
//  Tourus
//
//  Created by admin on 20/05/2019.
//  Copyright © 2019 Tourus. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class InteractionStory {
    let placeID:String?
    let userID:String
    var categories = [String]()
    let date:Date
    let userLocation:CLLocation
    let answer:Int
    var distanceBetweenUsers:Int? = nil
    
    init(place:Place, location:CLLocation, _answer:Int) {
        placeID = place.googleID
        userID = (MainModel.instance.currentUser()?.uid)!
        categories = place.types!
        date = Date()
        userLocation = location
        self.answer = _answer
    }
    
    
    init(json:[String:Any]) {
        let tmpDate = json["date"] as! Double
        date = Date(timeIntervalSince1970: tmpDate)
        categories = json["categories"] as! [String]
        placeID = (json["placeID"] as! String)
        userID = (json["userID"] as! String)
        let lat = json["userLocationLatitude"] as! Double
        let lng = json["userLocationLongitude"] as! Double
        userLocation = CLLocation(latitude: lat, longitude: lng)
        answer = json["answer"] as! Int
    }
    
    func toJson() -> [String:Any] {
        var json = [String:Any]()
        
        json["placeID"] = placeID
        json["userID"] = userID
        json["categories"] = categories
        json["date"] = date.timeIntervalSince1970
        json["userLocationLatitude"] = userLocation.coordinate.latitude
        json["userLocationLongitude"] = userLocation.coordinate.longitude
        json["answer"] = answer
        
        return json
    }
    
    func getDistanceInMeters (_ from:CLLocation) {
        distanceBetweenUsers = Int(userLocation.distance(from: from))
    }
}
