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
        
        GetCurrentPlace(callback: { place in () })
    }
    
    
    
    func fetchGoogleNearbyPlaces(key: String!, location: String!, radius: Int!, callback: @escaping ([Place]?, String?) -> Void) {
        var urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
        urlString+="location="+location
        urlString+="&radius="+String(radius)
        urlString+="&key="+key
        
        let urlObj = URL(string: urlString)
        URLSession.shared.dataTask(with: urlObj!) {(data, response, error) in
            do {
                if (error != nil) {
                    callback(nil,error?.localizedDescription)
                    return
                }
                let googlePlacesResponse = try JSONDecoder().decode(GooglePlacesResponse.self, from: data!)
                let status = googlePlacesResponse.status;
                if status == "NOT_FOUND" || status == "REQUEST_DENIED" {
                    //callback(nil,status)
                    return
                }
                callback(googlePlacesResponse.results.map({ (place) -> Place in
                    return Place(googlePlace : place)}),nil)
            } catch {
                callback(nil,error.localizedDescription)
            }
            }.resume()
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
}
