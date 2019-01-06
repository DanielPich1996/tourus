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
    
    
    
    
    @IBOutlet weak var verticalStackView: UIStackView!
    @IBOutlet var optionsStackHeightConstraint: NSLayoutConstraint!
    @IBOutlet var optionsView: UIView!
    
    var allButtons = [UIButton]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setInteraction(.question, "Hello to you")
        //addButtonsUsingStackView()
        addButtonsUsingStackView()
       
    }
    
    func addButtonsUsingStackView()
    {
        let buttonArray=["Button 1","Button 2","Button 444","Button 334","Button 334"]
        var i = 0

        verticalStackView.spacing = 15.0
        //verticalStackView.alignment = .fill
         //verticalStackView.distribution = .fillProportionally
        
        var panel:UIStackView? = nil
        // var subWidth:CGFloat = 0
        //var maxWidth:CGFloat = 0
        for buttonName in buttonArray{
            if(i % 2 == 0) {
                if(panel != nil) {
                    //let delta = optionsView.frame.width - maxWidth*2
                    //panel!.spacing = delta
                    
                    verticalStackView.addArrangedSubview(panel!)
                }
                
                panel = UIStackView()
                panel!.axis = .horizontal
                panel!.spacing = 15.0
                //subWidth = 0
            }
            
            let button = addingCustomButton(buttonTitle: buttonName, buttonFontSize: 15, buttonCount: i, buttonColor: UIColor.orange)
            button.contentMode = UIView.ContentMode.scaleToFill
            //subWidth += button.frame.size.width
            
            //if(subWidth > maxWidth) {
            //    maxWidth = subWidth
            //}
            
            panel!.addArrangedSubview(button)
            i += 1
        }
        
        verticalStackView.addArrangedSubview(panel!)
       
        
        optionsStackHeightConstraint.constant = CGFloat(25 * (i+1))
        self.view.layoutIfNeeded()
    }
    
    func addingCustomButton(buttonTitle : String, buttonFontSize: CGFloat, buttonCount : Int, buttonColor:UIColor) -> UIButton
    {
        let ownButton = UIButton()
        
        ownButton.setTitle(buttonTitle, for: UIControl.State.normal)
        
        
        ownButton.titleLabel?.font = UIFont.systemFont(ofSize: buttonFontSize)
        
        let buttonTitleSize = (buttonTitle as NSString).size(withAttributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: buttonFontSize + 1)])
        
        ownButton.frame.size.height = buttonTitleSize.height * 2
        ownButton.frame.size.width = buttonTitleSize.width
        //ownButton.frame.origin.x = 30
        
        //yPos = yPos + (ownButton.frame.size.height) + 10
        
        //ownButton.frame.origin.y = 10
        
        ownButton.tintColor = UIColor.white
        ownButton.backgroundColor = buttonColor
        
        ownButton.tag = buttonCount
        
        ownButton.setTitleColor(UIColor.darkGray, for: UIControl.State.highlighted)
        ownButton.addTarget(self, action: #selector(ownButtonAction), for: UIControl.Event.touchUpInside)
        
        return ownButton
    }
    
    @objc func ownButtonAction( _ button : UIButton)
    {
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
