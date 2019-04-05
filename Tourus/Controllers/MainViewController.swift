//
//  MainViewController.swift
//  Tourus
//
//  Created by admin on 03/01/2019.
//  Copyright © 2019 Tourus. All rights reserved.
//
import UIKit
import CoreLocation

class MainViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK:Local const props
    let optionButtonMinHeight = 20
    let optionButtonSpace = 10
    let minimumBottomConstraint:CGFloat = -30
    let defaultInfoImage:UIImage? = UIImage(named: "no_image") ?? nil
    let backgroundImage:UIImageView = UIImageView(frame: UIScreen.main.bounds)
    let locationManager = CLLocationManager()
    
    // MARK:Outlets
    @IBOutlet var settingsBtn: UIButton!
    @IBOutlet var navigationBtn: UIButton!
    @IBOutlet var mainView: UIView!
    @IBOutlet var interactionLabel: UILabel!
    @IBOutlet var interactionView: UIView!
    @IBOutlet var verticalStackView: UIStackView!
    @IBOutlet var optionsStackHeightConstraint: NSLayoutConstraint!
    @IBOutlet var optionsView: UIView!
    @IBOutlet var moreInfoView: UIView!
    @IBOutlet var inquiryImage: UIImageView!
    @IBOutlet var moreInfoImage: UIImageView!
    @IBOutlet var moreInfoButtonView: UIView!
    
    // MARK:Outlets - Constraints
    @IBOutlet var interactionSettingsConstraint: NSLayoutConstraint!
    @IBOutlet var settingsInteractionConstraint: NSLayoutConstraint!
    @IBOutlet var optionsBottomConstraint: NSLayoutConstraint!
    
    var interaction:Interaction? = nil
    var currUserLocation:CLLocation? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        verticalStackView.spacing = 15.0
        inquiryImage.isHidden = true
        navigationBtn.isHidden = true
        initLocationManager()
        addBackgroundImage()
        
        //temp code for testing:
        var categories = [String]()
        categories.append("bar")
        MainModel.instance.getInteraction(categories, { interact in
            self.interaction = interact
            if interaction != nil {
                self.setInteraction(self.interaction!)
            }
        })
    }
    
    @IBAction func navigationButtonAction(_ sender: Any) {
        if (interaction != nil && interaction?.place != nil) {
            navigate((interaction?.place)!)
        }
    }
    
    var count = 0
    @objc func optionButtonAction( _ button : UIOptionButton) {
        //what to do when an option button tapped?
        
        switch button.type {
        case .accept: //navigate if a place is exist
            if (interaction != nil && interaction?.place != nil) {
                navigate((interaction?.place)!)
            }
        case .decline: break
        case .negative: break
        case .neutral: break
        case .opinionless: break
        case .additional: break
        }
        
        //tmp code for simulation:
        let latitude:String = String(format: "%f", currUserLocation!.coordinate.latitude)
        let longitude:String = String(format:"%f", currUserLocation!.coordinate.longitude)
        let loc:String = latitude + "," + longitude
        
        MainModel.instance.fetchNearbyPlaces(location: loc, callback: { (places,err)  in
            DispatchQueue.main.async {
                if places != nil {
                    MainModel.instance.getInteraction(places![0].types, { intereact in
                        self.interaction = intereact
                        if self.interaction != nil {
                            self.interaction?.place = places![0]
                            
                            if(self.count % 2 == 0) {
                                self.interaction?.type = .question
                                self.setInteractionwithAnimation(self.interaction!)
                            } else {
                                self.setInteractionwithAnimation(self.interaction!)
                            }
                            
                            self.count += 1
                        }                       
                    })
                }
            }
        })
    }

    @IBAction func onSettingsClick(_ sender: Any) {
        //do something when settings button tapped?
    }

    // MARK:Navigation funcs
    private func navigate(_ place:Place) {
        let lat = String((place.location?.lat)!)
        let long = String((place.location?.lng)!)
            
        MainModel.instance.navigate(lat, long)
    }
    
    // MARK:Background image funcs
    private func setBackroundImage(_ image:UIImage?) {
        DispatchQueue.main.async {
            self.backgroundImage.image = image
        }
    }
    
    private func setInfoImage(_ image:UIImage?) {
        DispatchQueue.main.async {
            //self.removeInfoImage()
            if image == nil {
                 self.moreInfoImage.image = self.defaultInfoImage
            }
            else {
                self.moreInfoImage.image = image
            }
        }
    }
    
    // MARK:interaction setting funcs
    func setInteractionwithAnimation(_ interaction:Interaction) {
        optionsView.fadeOut()
        //navigationBtn.fadeOut()
        interactionView.fadeOut()
        if let preImageView = self.view.viewWithTag(100) {
            preImageView.fadeOut()
        }
        moreInfoView.fadeOut() { (res) in
            self.setInteraction(interaction)
            
            //self.navigationBtn.fadeIn()
            self.optionsView.fadeIn()
            self.interactionView.fadeIn()
            self.moreInfoView.fadeIn()
            
            if let preImageView = self.view.viewWithTag(100) {
                preImageView.fadeIn()
            }
        }
    }
    
    @IBAction func moreInfoTapped(_ sender: Any) {
        
    }
    
    func setInteraction(_ interaction:Interaction) {
        //navigationBtn.isEnabled = true
        //navigationBtn.isHidden = true
        moreInfoView.isHidden = true
        
        let topConstraint:CGFloat = self.view.frame.height / 5
        var bottomConstraint:CGFloat = 0
        var interactionBackOpacity:CGFloat = 0

        setBackroundImage(nil)
        setInfoImage(nil)
        
        switch interaction.type {
        case .question:
            do {
                bottomConstraint = (self.view.frame.height / 5 - moreInfoView.frame.height) * -1
            }
        case .info:
            do {
                bottomConstraint = (self.view.frame.height / 5 - moreInfoView.frame.height) * -1
            }
        case .suggestion:
            do {
                interactionBackOpacity = 0.3
                //navigationBtn.isHidden = false
                moreInfoView.isHidden = false
                
                //if interaction.place == nil {
                //     navigationBtn.isEnabled = false
                //}
                
                if(interaction.place != nil  && interaction.place!.picturesUrls.count > 0) {
                    MainModel.instance.getPlaceImage(interaction.place!.picturesUrls[0], 800, 0.4, setBackroundImage)

                    if(interaction.place!.picturesUrls.count > 1) {
                        MainModel.instance.getPlaceImage(interaction.place!.picturesUrls[1], 800, 1, setBackroundImage)
                    }
                }
            }
        }
        
        //checking the new bottom constraint. taking the minimum
        if(bottomConstraint > minimumBottomConstraint) {
            bottomConstraint = minimumBottomConstraint
        }
        //back colors of sub views
        interactionView.backgroundColor = UIColor(white: 0, alpha: interactionBackOpacity)
        moreInfoView.backgroundColor = UIColor(white: 0, alpha: interactionBackOpacity)
        optionsView.backgroundColor = UIColor(white: 0, alpha: interactionBackOpacity)
        //constraints of interaction text distance from settings button
        interactionSettingsConstraint.constant = topConstraint
        settingsInteractionConstraint.constant = topConstraint
        optionsBottomConstraint.constant = bottomConstraint
        
        interactionLabel.text = interaction.text
        //setting the option buttons
        setOptionsButtons(interaction.options)
    }
  
    func setOptionsButtons(_ options:[Interaction.Option])
    {
        for view in verticalStackView.subviews {
            view.removeFromSuperview()
        }
        
        var panel:UIStackView? = nil
        var subWidth:CGFloat = 0
        var maxWidth:CGFloat = 0
        var i = 0
        let sortedOptions = options.sorted(by: { $0.type.rawValue < $1.type.rawValue })
        
        for option in sortedOptions {
            if(i % 2 == 0) {
                if(panel != nil) {
                    let delta = (optionsView.frame.width - maxWidth) / 2
                    panel!.spacing = delta
                    verticalStackView.addArrangedSubview(panel!)
                }
                
                panel = UIStackView()
                panel!.axis = .horizontal
                panel!.spacing = 15.0
                subWidth = 0
            }
            
            let button = UIOptionButton(option: option, tag: i)
            button.addTarget(self, action: #selector(optionButtonAction), for: UIControl.Event.touchUpInside)
            subWidth += button.frame.size.width
            
            if(subWidth > maxWidth) {
                maxWidth = subWidth
            }
            
            panel!.addArrangedSubview(button)
            i += 1
        }
        
        if(panel != nil) {
            let delta = (optionsView.frame.width - maxWidth) / 2
            panel!.spacing = delta
            verticalStackView.addArrangedSubview(panel!)
        }
        
        optionsStackHeightConstraint.constant = CGFloat((optionButtonMinHeight + optionButtonSpace) * (i+1))
        self.view.layoutIfNeeded()
    }
    
    private func addBackgroundImage() {
        backgroundImage.tag = 100
        backgroundImage.contentMode = UIView.ContentMode.scaleAspectFill
        backgroundImage.alpha = 0.0
        self.view.insertSubview(backgroundImage, at: 0)
    }
    
    ///MARK: Location Manager Functions
    func initLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        enableLocationServices()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 && currUserLocation == nil {
            currUserLocation = location
            locationManager.stopUpdatingLocation()
            let strLocation = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
            MainModel.instance.fetchNearbyPlaces(location: strLocation, type:"restaurant", callback: {(places, error) in
                print(places!)
            })
        }
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func updateLocation(){
        currUserLocation = nil
        locationManager.startUpdatingLocation()
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
}
