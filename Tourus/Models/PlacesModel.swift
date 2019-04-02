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
    var placesClient: GMSPlacesClient! = GMSPlacesClient.shared()
    var currPlace : Place? = nil
    let apiWebKey = "AIzaSyChHqn4cqme0MTgu6QRmaJHppcGs_NbeIc"
    let maxW = 200
    
    init() {
        
    }
    
    
    
    func fetchGoogleNearbyPlaces(location: String!, radius: Int!, type:String? = nil, isOpen:Bool?=true, callback: @escaping ([Place]?, String?) -> Void) {
        var urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
        urlString+="location="+location
        urlString+="&radius="+String(radius)
        urlString+="&key="+apiWebKey
        //urlString+="&fields=photos" //,formatted_address,name,rating,opening_hours"
        urlString+="&language=en"
        
        if isOpen! {
            urlString+="&opennow"
        }
        if let strType = type {
            urlString+="&type=\(strType)"
        }
        
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
    
    func fetchGoogleNearbyPlacesPhoto(_ reference:String, _ maxwidth:Int,_ callback: @escaping (UIImage?) -> Void) {

        // Method 3
        let urlString = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=\(maxwidth)&photoreference=\(reference)&key=\(apiWebKey)"
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
