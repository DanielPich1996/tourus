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
    
    init(googlePlace:GMSPlace?) {
        if googlePlace != nil {
            name = googlePlace!.name!
            address = ((googlePlace!.formattedAddress?.components(separatedBy: ", ").joined(separator: "\n"))!)
        }
    }
}
