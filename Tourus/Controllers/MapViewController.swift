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
    @IBOutlet weak var ArrivalLabel: UILabel!
    
    let locationManager = CLLocationManager()
    var currentCoordinate: CLLocationCoordinate2D!
    
    var lat:Double? = nil
    var long:Double? = nil
    
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
    
    @IBAction func onExitTap(_ sender: Any) {
        
       self.alertStoppingNavigation()
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
                
                let region = CLCircularRegion(center: step.polyline.coordinate, radius: 2, identifier: "\(i)")
                
                self.locationManager.startMonitoring(for: region)
                let circle = MKCircle(center: region.center, radius: region.radius)
                self.mapView.addOverlay(circle)
            }
            
            self.setArrivalData(primaryRoute)
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
    
    func setArrivalData(_ route:MKRoute) {
        
        let distance = Int(route.distance)
        let travelTime = route.expectedTravelTime.toDisplayString()
        
        ArrivalLabel.text = "total of \(distance)m to arrive in \(travelTime)"
    }
}

extension MapViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
       
        manager.stopUpdatingLocation()
        guard let currentLocation = locations.first else { return }
        
        
        if lat != nil && long != nil {
            
            currentCoordinate = currentLocation.coordinate
            //follows the user's direction by the phone rotating
            mapView.userTrackingMode = .followWithHeading
            
            getDirections(to: MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: lat!, longitude: long!))))
        } else {
            //error - no lat nor long were found
            self.stopNavigation()
            self.dismissAndGoToMain()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {

        stepCounter += 1
        let stepIndex = Int(region.identifier)
        
        if stepIndex != nil {
            let currentStep = steps[stepIndex!]
            if stepIndex! < steps.count-1 {
                setDirections(currentStep)
            } else {
                //arrived
                let message = "Arrived at destination"
                setDirections(message)
                stopNavigation()
            }
        } else {
            stopNavigation()
        }
    }
    
    func stopNavigation() {
        
        //remove regions
        self.locationManager.monitoredRegions.forEach({ self.locationManager.stopMonitoring(for: $0)})
        //remove overlays
        self.mapView.overlays.forEach {
            if !($0 is MKUserLocation) {
                self.mapView.removeOverlay($0)
            }
        }
    }
    
    func alertStoppingNavigation() {
        
        //Create the alert controller and actions
        let alert = UIAlertController(title: "Navigation", message: "Back for another attraction?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        let acceptAction = UIAlertAction(title: "Yes", style: .destructive) { _ in
            DispatchQueue.main.async {
                self.dismissAndGoToMain()
            }
        }
        
        //Add the actions to the alert controller
        alert.addAction(cancelAction)
        alert.addAction(acceptAction)
        
        //Present the alert controller
        present(alert, animated: true, completion: nil)
    }
    
    func dismissAndGoToMain() {
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let mainVC = mainStoryboard.instantiateViewController(withIdentifier: "MainViewController") as? MainViewController else { return }
        present(mainVC, animated: true, completion: nil)
    }
}

extension MapViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay is MKPolyline {
            
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .directionColor
            renderer.lineWidth = 4
            
            return renderer
        }
        
        if overlay is MKCircle {
            
            let renderer = MKCircleRenderer(overlay: overlay)
            
            renderer.strokeColor = .directionPointColor
            renderer.fillColor = .directionColor
            renderer.alpha = 0.8
            
            return renderer
        }
        
        return MKOverlayRenderer()
    }
}

extension TimeInterval {
    
    func toDisplayString() -> String {
        
        let time = NSInteger(self)
        
        //let ms = Int((self.truncatingRemainder(dividingBy: 1)) * 1000)
        //let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        
        return String(format: "%0.2d:%0.2d",hours,minutes)
        
    }
}
