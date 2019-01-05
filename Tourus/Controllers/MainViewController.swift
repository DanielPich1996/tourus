//
//  MainViewController.swift
//  Tourus
//
//  Created by admin on 03/01/2019.
//  Copyright © 2019 Tourus. All rights reserved.
//
import UIKit

enum InteractionType {
    case question
    case info
    case suggestion
}

class MainViewController: UIViewController {
    // MARK:Outlets
    @IBOutlet var settingsBtn: UIButton!
    @IBOutlet var mainView: UIView!
    @IBOutlet var interactionLabel: UILabel!
    @IBOutlet var interactionView: UIView!
    // MARK:Outlets - Constraints
    @IBOutlet var interactionSettingsConstraint: NSLayoutConstraint!
    @IBOutlet var settingsInteractionConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setInteraction(.question, "Hello to you")
    }
    
    var counter:Int = 0
    @IBAction func onSettingsClick(_ sender: Any) {
        //temp code
        if(counter % 2 == 0) {
            setInteraction(.suggestion, "Wanna meet each other a bit with some questions?")
        } else {
            setInteraction(.question, "Hello to you")
        }
       
        counter += 1
    }
    
    // MARK:Interaction functions
    private func setInteraction(_ type:InteractionType, _ text:String) {
        var topConstraint:CGFloat = 30
        var interactionBackOpacity:CGFloat = 0
    
        switch type {
            case .question:
            do {
                setBackroundImage(nil)
            }
            case .info:
            do {
                setBackroundImage(nil)
            }
            case .suggestion:
            do {
                topConstraint = self.view.frame.height / 5
                interactionBackOpacity = 0.2
                setBackroundImage(UIImage(named: "pizza")!.alpha(0.3))
            }
        }
        
        interactionLabel.text = text
            
        interactionSettingsConstraint.constant = topConstraint
        settingsInteractionConstraint.constant = topConstraint
    
        interactionView.backgroundColor = UIColor(white: 0, alpha: interactionBackOpacity)
    }
    
    // MARK:Background image functions
    private func setBackroundImage(_ image:UIImage?) {
        if let preImageView = self.view.viewWithTag(100) {
            preImageView.removeFromSuperview()
        }
        
        if (image != nil) {
            let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
            backgroundImage.tag = 100
            backgroundImage.image = image!
            backgroundImage.contentMode = UIView.ContentMode.scaleAspectFill
        
            self.view.insertSubview(backgroundImage, at: 0)
        }
    }
}



extension UIImage {
    func alpha(_ value:CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
