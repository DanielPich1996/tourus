//
//  GooglePlace.swift
//  Tourus
//
//  Created by admin on 30/03/2019.
//  Copyright © 2019 Tourus. All rights reserved.
//

import Foundation
import GooglePlaces



class GooglePlace : Decodable{
    let place_id: String!
    let geometry: Geometry!
    let name: String!
    let opening_hours: OpeningHours?
    let photos: [Photo]?
    let price_level: Int?
    let rating: Double?
    let types: [String]?
    let user_ratings_total: Int?
    let vicinity: String?
}


class Geometry: Decodable {
    let location: Location!
}

class Location: Decodable {
    let lat, lng: Double!
    
    init(lat: Double!, lng: Double!) {
        self.lat = lat
        self.lng = lng
    }
}

class OpeningHours: Decodable {
    let open_now: Bool?
}

class Photo: Decodable {
    let height: Int?
    let htmlAttributions: [String]?
    let photoReference: String?
    let width: Int?
    
    enum CodingKeys: String, CodingKey {
        case height
        case htmlAttributions = "html_attributions"
        case photoReference = "photo_reference"
        case width
    }
    
    init(height: Int?, htmlAttributions: [String]?, photoReference: String?, width: Int?) {
        self.height = height
        self.htmlAttributions = htmlAttributions
        self.photoReference = photoReference
        self.width = width
    }
}

class GooglePlacePhotos : Decodable{
    let photos: [Photo]?
}

