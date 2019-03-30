//
//  Place.swift
//  Tourus
//
//  Created by admin on 02/03/2019.
//  Copyright © 2019 Tourus. All rights reserved.
//

import Foundation
import GooglePlaces

class Place {
    var name:String = ""
    var address:String = ""
    var picturesUrls:[String]? = nil
    var rating: Double? = nil
    var ratingsAmount: Int? = nil
    var priceLevel: Int? = nil
    var types: [String]? = nil
    var isOpen: Bool? = nil

    init(googlePlace:GMSPlace?) {
        if googlePlace != nil {
            name = googlePlace!.name!
            address = ((googlePlace!.formattedAddress?.components(separatedBy: ", ").joined(separator: "\n"))!)
        }
    }
    
    init(googlePlace:GooglePlace?) {
        if googlePlace != nil {
            name = googlePlace!.name ?? ""
            address = String(googlePlace!.geometry.location.lat) + "," + String(googlePlace!.geometry.location.lng)
            rating = googlePlace?.rating
            ratingsAmount = googlePlace?.user_ratings_total
            priceLevel = googlePlace?.price_level
            types = googlePlace?.types
            isOpen = googlePlace?.opening_hours?.open_now
        }
    }
}
