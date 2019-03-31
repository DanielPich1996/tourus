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
    var currPlace : Place? = nil
    
    init() {
        enableLocationServices()
        
        GetCurrentPlace(callback: { place in () })
        
        //NSURL googlePlacesURL = [NSURL (fileURLWithPath: "https://maps.googleapis.com/maps/api/place/search/json?location9=34.0522222,-118.2427778&radius=500&types=museum|art_gallery&sensor=false&key=AIzaSyBjnEwXHsPT3DafV_Ud2BKrscJQ_ll0XRI")]
        
        //googlePlacesResult()
        fetchGoogleNearbyPlaces(key: "AIzaSyChHqn4cqme0MTgu6QRmaJHppcGs_NbeIc",location: "-33.8670522,151.1957362",radius: 500) {
            (places:[Place]?, err:String?) in
            if(places != nil) {
                places?.forEach { place in
                    self.fetchGoogleNearbyPlacesPhoto(place.picturesUrls[0], {(image) in  })
                    print(place)}
            }
        }
    }
    
    
    
    func fetchGoogleNearbyPlaces(key: String!, location: String!, radius: Int!, callback: @escaping ([Place]?, String?) -> Void) {
        var urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
        urlString+="location="+location
        urlString+="&radius="+String(radius)
        urlString+="&key="+key
        urlString+="&fields=photos" //,formatted_address,name,rating,opening_hours"
        
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
    
    func fetchGoogleNearbyPlacesPhoto(_ reference:String, _ callback: @escaping (UIImage?) -> Void) {
//        //Method 1
//        var photoMetadata : GMSPlacePhotoMetadata = photo
//        self.placesClient?.loadPlacePhoto(photoMetadata, callback: { (photo, error) -> Void in
//            if let error = error {
//                // TODO: Handle the error.
//                print("Error loading photo metadata: \(error.localizedDescription)")
//                return
//            } else {
//                callback(photo)
//            }
//        })
//
//
//        // Method 2
//        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.photos.rawValue))!
//
//        placesClient?.fetchPlace(fromPlaceID: placeID, placeFields: fields, sessionToken: nil, callback: {
//                                (place: GMSPlace?, error: Error?) in
//                                    if let error = error {
//                                        print("An error occurred: \(error.localizedDescription)")
//                                        return
//                                    }
//                                    if let place = place {
//                                        // Get the metadata for the first photo in the place photo metadata list.
//                                        let photoMetadata: GMSPlacePhotoMetadata = place.photos![0]
//
//                                        // Call loadPlacePhoto to display the bitmap and attribution.
//                                        self.placesClient?.loadPlacePhoto(photoMetadata, callback: { (photo, error) -> Void in
//                                            if let error = error {
//                                                // TODO: Handle the error.
//                                                print("Error loading photo metadata: \(error.localizedDescription)")
//                                                return
//                                            } else {
//                                                // Display the first image and its attributions.
//                                               callback(photo)
//                                            }
//                                        })
//                                    }
//        })
        // Method 3
        let urlString = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=200&photoreference=\(reference)&key=AIzaSyChHqn4cqme0MTgu6QRmaJHppcGs_NbeIc"
        let url = URL(string: urlString)
        
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        URLSession.shared.downloadTask(with: url!) { url, response, error in
            var downloadedPhoto: UIImage? = nil
            defer {
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            }
            guard let url = url else {
                return
            }
            guard let imageData = try? Data(contentsOf: url) else {
                return
            }
            downloadedPhoto = UIImage(data: imageData)
            callback(downloadedPhoto)
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
