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
    
    private var directed = false

    var steps = [MKRoute.Step]()
    var route:MKRoute? = nil
    let speechSynthesizer = AVSpeechSynthesizer()
    
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
    
    @IBAction func onNavigateTap(_ sender: Any) {
        
        self.alertNavigationRefresh()
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
            
            self.stopNavigation()
            
            self.route = primaryRoute
            //add a polyline path to the map
            self.mapView.addOverlay(primaryRoute.polyline)
            
            //add polyline steps to the map
            self.steps = primaryRoute.steps
            for i in 0 ..< primaryRoute.steps.count {
                let step = primaryRoute.steps[i]
                
                print(step.instructions)
                print(step.distance)
                
                let region = CLCircularRegion(center: step.polyline.coordinate, radius: 10, identifier: "\(i)")
                
                self.locationManager.startMonitoring(for: region)
                let circle = MKCircle(center: region.center, radius: region.radius)
                self.mapView.addOverlay(circle)
            }

            self.setArrivalData(primaryRoute)
            self.setDirections(self.steps[0])
        }
    }
    
    func getDirectionsFormat(_ step:MKRoute.Step) -> String {
        
        let distanceInt = Int(step.distance)
        if step.instructions.isEmpty {
            return "Walk forward for \(distanceInt) meters"
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

        let distance = String(format: "%.1f Km", route.distance/1000)
        let travelTime = route.expectedTravelTime.toDisplayString()

        ArrivalLabel.text = "\(distance) away" + "\n" + "arrive in \(travelTime)"
    }
    
    func navigate() {
        
        if lat != nil && long != nil {
            //follows the user's direction by the phone rotating
            mapView.userTrackingMode = .followWithHeading
            
            getDirections(to: MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: lat!, longitude: long!))))
        } else {
            //error - no lat nor long were found
            self.stopNavigation()
            self.dismissAndGoToMain()
        }
    }
    
    func navigateIfUserIsFarFromRoute() {
        
        var closestDistance:Int? = nil
        for step in self.steps {
            
            let userPoint  = MKMapPoint(currentCoordinate)
            let routePoint = MKMapPoint(step.polyline.coordinate)
            
            let distance = Int(userPoint.distance(to: routePoint))
            
            if closestDistance == nil || distance < closestDistance! {
                closestDistance = distance
            }
        }
        
        if closestDistance != nil && closestDistance! > consts.map.maxFarFromRouteInMeters {
            //far from route - navigate again
            
            getDirections(to: MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: lat!, longitude: long!))))
        }
    }
}

extension MapViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
       
        //manager.stopUpdatingLocation()
        guard let currentLocation = locations.first else { return }
        currentCoordinate = currentLocation.coordinate
        
        if !directed {
            
            directed = true
            navigate()
            
        } else { navigateIfUserIsFarFromRoute() }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {

        let stepIndex = Int(region.identifier)
        if stepIndex == 0 { return } //we've already directed the user by the first step
        
        if stepIndex != nil {
            let currentStep = steps[stepIndex!]
            if stepIndex! < (steps.count-1) {
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
    
    func alertNavigationRefresh() {
        
        let alert = UIAlertController(title: "Navigation", message: "Refresh navigation for you'r attraction?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let acceptAction = UIAlertAction(title: "Refresh", style: .destructive) { _ in
            DispatchQueue.main.async {
                self.route = nil
                self.steps = [MKRoute.Step]()
                
                self.navigate()
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
        let minutes = Int((time / 60) % 60)
        let hours = Int(time / 3600)
        
        var message = String(format: "%.1d Minutes", minutes)
        if hours > 0 {
            message = String(format: "%.1d:%02d Hours", hours, minutes)
        }
        
        return message
    }
}
