//
//  MapViewController.swift
//  Tourus
//
//  Created by admin on 27/05/2019.
//  Copyright © 2019 Tourus. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import AVFoundation

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var directionLabel: UILabel!
    
    let locationManager = CLLocationManager()
    var currentCoordinate: CLLocationCoordinate2D!
    
    var steps = [MKRoute.Step]()
    let speechSynthesizer = AVSpeechSynthesizer()
    
    var stepCounter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.startUpdatingLocation()
    }
    
    func getDirections(to destination: MKMapItem) {
        let sourcePlacemark = MKPlacemark(coordinate: currentCoordinate)
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        
        let directionsReq = MKDirections.Request()
        directionsReq.source = sourceMapItem
        directionsReq.destination = destination
        directionsReq.transportType = .walking
        
        let directions = MKDirections(request: directionsReq)
        directions.calculate { (response, _) in
            guard let response = response else { return }
            guard let primaryRoute = response.routes.first else { return }
        
            //add a polyline path to the map
            self.mapView.addOverlay(primaryRoute.polyline)
            
            self.locationManager.monitoredRegions.forEach({ self.locationManager.stopMonitoring(for: $0)})
            
            //add polyline steps to the map
            self.steps = primaryRoute.steps
            for i in 0 ..< primaryRoute.steps.count {
                let step = primaryRoute.steps[i]
                
                print(step.instructions)
                print(step.distance)
                
                let region = CLCircularRegion(center: step.polyline.coordinate, radius: 5, identifier: "\(i)")
                
                self.locationManager.startMonitoring(for: region)
                let circle = MKCircle(center: region.center, radius: region.radius)
                self.mapView.addOverlay(circle)
            }
            
            self.setDirections(self.steps[0])
            self.stepCounter += 1
        }
    }
    
    func getDirectionsFormat(_ step:MKRoute.Step) -> String {
        
        let distanceInt = Int(step.distance)
        if step.instructions.isEmpty {
            return "Go \(distanceInt) meters"
        } else {
            return "In \(distanceInt) meters \(step.instructions)"
        }
    }
    
    func setDirections(_ step:MKRoute.Step) {
        let directions = getDirectionsFormat(step)
        setDirections(directions)
    }
    
    func setDirections(_ directions:String) {
        self.directionLabel.text = directions
        let speechUtterance = AVSpeechUtterance(string: directions)
        self.speechSynthesizer.speak(speechUtterance)
    }
}

extension MapViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
       
        manager.stopUpdatingLocation()
        guard  let currentLocation = locations.first else { return }
        currentCoordinate = currentLocation.coordinate
        
        //follows the user's direction by the phone rotating
        mapView.userTrackingMode = .followWithHeading
        
        
        getDirections(to: MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 32.0470902, longitude: 34.9554104))))
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {

        stepCounter += 1
        
        if stepCounter < steps.count {
            let currentStep = steps[stepCounter]
            self.setDirections(currentStep)
        } else {
            //arrived
            let message = "Arrived at destination"
            setDirections(message)
            stepCounter = 0
            //remove regions
            self.locationManager.monitoredRegions.forEach({ self.locationManager.stopMonitoring(for: $0)})
        }
    }
}

extension MapViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay is MKPolyline {
            
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .blue
            renderer.lineWidth = 5
            
            return renderer
        }
        
        if overlay is MKCircle {
            
            let renderer = MKCircleRenderer(overlay: overlay)
            
            renderer.strokeColor = .red
            renderer.fillColor = .red
            renderer.alpha = 0.5
            
            return renderer
        }
        
        return MKOverlayRenderer()
    }
}
