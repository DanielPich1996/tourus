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
    
    var lat:Double? = nil
    var long:Double? = nil
    var destinationName:String? = nil
    var destinationRating:Double? = nil
    
    private let locationManager = CLLocationManager()
    private var currentCoordinate: CLLocationCoordinate2D!
    private var directed = false
    private var steps = [MKRoute.Step]()
    private var route:MKRoute? = nil
    private let speechSynthesizer = AVSpeechSynthesizer()
    private var isDirectionalAudioOn = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let settings = MainModel.instance.getSettings() {
            isDirectionalAudioOn = settings.isDirectionalAudioOn
        }
        
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.startUpdatingLocation()
    }
    
    func setDestinationData(destLat:Double?, destlong:Double?, destName:String?, destRating:Double?) {
        
        lat = destLat
        long = destlong
        destinationName = destName
        destinationRating = destRating
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
                
                //let region = CLRegion( MTLRegion(origin: nil, size: nil)
                let region = CLCircularRegion(center: step.polyline.coordinate, radius: 10, identifier: "\(i)")
                
                self.locationManager.startMonitoring(for: region)
                let circle = MKCircle(center: region.center, radius: region.radius)
                self.mapView.addOverlay(circle)
            }
            
            //add destination pin
            let annotation = DestinationPointAnnotation()
            annotation.title = self.destinationName
            annotation.coordinate = primaryRoute.steps[primaryRoute.steps.count-1].polyline.coordinate
            self.mapView.addAnnotation(annotation)
            
            //set durections
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
        
        if isDirectionalAudioOn {
            let speechUtterance = AVSpeechUtterance(string: directions)
            self.speechSynthesizer.speak(speechUtterance)
        }
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
    
    func calculateMaxDistanceFromRoute() {
        
        var farestDistance:Int? = nil
        guard let currentRoute = route else { return }
        
        //calculating the center point of the route
        let centerRoutePoint  = MKMapPoint(currentRoute.polyline.coordinate)

        for step in self.steps {
            //calculating the current step distance from the center of the entire route
            let stepPoint = MKMapPoint(step.polyline.coordinate)
            let distance = Int(centerRoutePoint.distance(to: stepPoint))
            //taking the max distance
            if farestDistance == nil || distance > farestDistance! {
                farestDistance = distance
            }
        }
        
        guard var maxDistance = farestDistance else { return }
        maxDistance += consts.map.maxFarFromRouteInMeters
        //calculating user point
        let userPoint  = MKMapPoint(currentCoordinate)
        let userDistance = Int(centerRoutePoint.distance(to: userPoint))
        
        if  userDistance > maxDistance {
            //far from route - navigate again
            getDirections(to: MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: lat!, longitude: long!))))
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination is MoreInfoViewController {
            let vc = segue.destination as? MoreInfoViewController
            vc?.displayInteractionInfo(name: destinationName, rating: destinationRating)
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
            
        } else { calculateMaxDistanceFromRoute() }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {

        guard let stepIndex = Int(region.identifier) else { stopNavigation(); return }
        if stepIndex == 0 { return } //we've already directed the user by the first step
        
        let currentStep = steps[stepIndex]
        if stepIndex < (steps.count-1) {
            setDirections(currentStep)
        } else {
            //arrived
            let message = "Arrived at destination"
            setDirections(message)
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
        //remove annotations
        self.mapView.annotations.forEach {
            if !($0 is MKUserLocation) {
                self.mapView.removeAnnotation($0)
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is DestinationPointAnnotation {
            
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: consts.map.destinationPinIdentifier)
            
            if annotationView == nil {
                annotationView = DestinationAnnotationView(annotation: annotation, reuseIdentifier: consts.map.destinationPinIdentifier)
                
                annotationView?.image = UIImage(named: "destinationPin.png")
            } else {
                annotationView?.annotation = annotation
            }
            
            return annotationView
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if view is DestinationAnnotationView {
            
            let destView = view as! DestinationAnnotationView
            
            destView.selected()
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        
        if view is DestinationAnnotationView {
            
            let destView = view as! DestinationAnnotationView
            
            destView.deselected()
        }
    }
    
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

class DestinationAnnotationView: MKAnnotationView {
    
    private var originalTransform: CGAffineTransform? = nil
    private let annotationFrame = CGRect(x: 0, y: 0, width: 100, height: 20)
    private let label: UILabel
    
    override var annotation: MKAnnotation? {
        didSet {
            
            updateTitleLabel()
            if originalTransform == nil {
                
                transform = transform.scaledBy(x: 0.9, y: 0.9)
                originalTransform = CGAffineTransform(a: transform.a, b: transform.b, c: transform.c, d: transform.d, tx: transform.tx, ty: transform.ty)
            }
        }
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {

        label = UILabel(frame: annotationFrame.offsetBy(dx: -15, dy: 55))
        
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        canShowCallout = false
        backgroundColor = .clear
        frame = annotationFrame
    }
    
    required init?(coder aDecoder: NSCoder) {
        label = UILabel(frame: annotationFrame)
        super.init(coder: aDecoder)
    }
    
    private func updateTitleLabel() {
        
        if subviews.contains(label) {
            willRemoveSubview(label)
        }
        
        guard let title = annotation?.title else { return }
        
        label.alpha = 0
        label.textAlignment = .center
        
        let strokeTextAttributes = [
            NSAttributedString.Key.strokeColor : UIColor.destinationBorderPointColor,
            NSAttributedString.Key.foregroundColor : UIColor.destinationPointColor,
            NSAttributedString.Key.strokeWidth : -4.0,
            NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 10)
            ] as [NSAttributedString.Key : Any] as [NSAttributedString.Key : Any]
        
        label.attributedText = NSMutableAttributedString(string: title ?? "", attributes: strokeTextAttributes)
        
        label.numberOfLines = 0;
        label.sizeToFit()
        
        addSubview(label)
    }
    
    func selected() {
        
        guard let transform = originalTransform else { return }
        
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveLinear, animations: {
            
            self.transform = transform.scaledBy(x: 1.3, y: 1.3)
            self.label.alpha = 1
        })
    }
    
    func deselected() {
        
        guard let transform = originalTransform else { return }

        UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveLinear, animations: {
            
            self.transform = transform
            self.label.alpha = 0
        })
    }
}

class DestinationPointAnnotation : MKPointAnnotation {
    
}
