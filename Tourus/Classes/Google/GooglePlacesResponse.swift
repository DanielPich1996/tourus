//
//  GooglePlacesResponse.swift
//  Tourus
//
//  Created by admin on 30/03/2019.
//  Copyright © 2019 Tourus. All rights reserved.
//

import Foundation

class GooglePlacesResponse : Decodable {
    let status: String
    let results: [GooglePlace]
}
