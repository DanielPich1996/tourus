//
//  PlacesModel.swift
//  Tourus
//
//  Created by admin on 02/03/2019.
//  Copyright © 2019 Tourus. All rights reserved.
//

import Foundation
import GooglePlaces

class PlacesModel {
    let locationManager = CLLocationManager()
    var placesClient: GMSPlacesClient! = GMSPlacesClient.shared()

    init() {
        enableLocationServices()        
    }
    
    private func enableLocationServices() {
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .notDetermined:
            // Request when-in-use authorization initially
            locationManager.requestAlwaysAuthorization()
            break
            
        case .restricted, .denied:
            // Disable location features
            break
            
        case .authorizedWhenInUse:
            // Enable basic location features
            break
            
        case .authorizedAlways:
            // Enable any of your app's location features
            break
        }
    }
    
    func GetCurrentPlace(callback: @escaping (Place)-> Void) {
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            if let placeLikelihoodList = placeLikelihoodList {
                let place = placeLikelihoodList.likelihoods.first?.place
                if let place = place {
                        callback(Place(googlePlace: place))
                }
            }
        })
    }
    
    //A function that returns only if user is leaving the place.
    func isLeavingPlace() {
        var isStillThere = true
        var probablyFirstPlace : String?
        var probablySecondPlace : String?

        // Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
            UInt(GMSPlaceField.placeID.rawValue))!
        placesClient?.findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: fields, callback: {
            (placeLikelihoodList: Array<GMSPlaceLikelihood>?, error: Error?) in
            if let error = error {
                print("An error occurred: \(error.localizedDescription)")
                return
            }
            
            
            if let placeLikelihoodList = placeLikelihoodList {
                
                probablyFirstPlace = placeLikelihoodList.first?.place.placeID
            }
        })
    
        while isStillThere {
            sleep(10)
            placesClient?.findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: fields, callback: {
                (placeLikelihoodList: Array<GMSPlaceLikelihood>?, error: Error?) in
                if let error = error {
                    print("An error occurred: \(error.localizedDescription)")
                    return
                }
                
                if let placeLikelihoodList = placeLikelihoodList {
                    
                    probablySecondPlace = placeLikelihoodList.first?.place.placeID
                }
            })
            
            if probablyFirstPlace != probablySecondPlace {
                isStillThere = false
            }
        }
    }
}
