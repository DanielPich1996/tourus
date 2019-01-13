//
//  MainViewController.swift
//  Tourus
//
//  Created by admin on 03/01/2019.
//  Copyright © 2019 Tourus. All rights reserved.
//
import UIKit

class MainViewController: UIViewController {
    // MARK:Local const props
    let optionButtonMinHeight = 20
    let optionButtonSpace = 10
    let minimumBottomConstraint:CGFloat = -30
    
    // MARK:Outlets
    @IBOutlet var settingsBtn: UIButton!
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
    
    var interaction1:Interaction? = nil
    var interaction2:Interaction? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        
        verticalStackView.spacing = 15.0
        inquiryImage.isHidden = true
        
        //sample 1 of interaction set:
        let options1:[Interaction.Option] =  [ Interaction.Option(.positive, "I love pubs"), Interaction.Option(.negative, "Clubs sounds\nbetter"), Interaction.Option(.neutral, "Something different")]
        interaction1 = Interaction(.question, "How pubs sounds like?", options1)
        //sample 2 of interaction set:
        let options2:[Interaction.Option] =  [ Interaction.Option(.positive, "Let's go!"), Interaction.Option(.negative, "Not hungry\nbut thanx")]
        interaction2 = Interaction(.suggestion, "What about a yummy\npizza near by?", options2)
        
        setInteraction(interaction1!)
    }
    
    
    var count = 0
    @objc func optionButtonAction( _ button : UIOptionButton)
    {
        //what to do when an option button tapped?
        if(count % 2 == 0) {
            setInteractionwithAnimation(interaction2!)
        } else {
            setInteractionwithAnimation(interaction1!)
        }
        
        self.count += 1//temp
    }
    
    @IBAction func onSettingsClick(_ sender: Any) {
        //do something when settings button tapped?
    }

    // MARK:Background image funcs
    private func setBackroundImage(_ image:UIImage?) {
        if let preImageView = self.view.viewWithTag(100) {
            preImageView.removeFromSuperview()
        }
        
        if (image != nil) {
            let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
            backgroundImage.tag = 100
            backgroundImage.image = image!
            backgroundImage.contentMode = UIView.ContentMode.scaleAspectFill
            backgroundImage.alpha = 0.0
            
            self.view.insertSubview(backgroundImage, at: 0)
        }
    }

    // MARK:interaction setting funcs
    func setInteractionwithAnimation(_ interaction:Interaction) {
        optionsView.fadeOut()
        interactionView.fadeOut()
        if let preImageView = self.view.viewWithTag(100) {
            preImageView.fadeOut()
        }
        moreInfoView.fadeOut() { (res) in
            self.setInteraction(interaction)
            
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
        let topConstraint:CGFloat = self.view.frame.height / 5
        var bottomConstraint:CGFloat = 0
        var interactionBackOpacity:CGFloat = 0
        
        switch interaction.type {
        case .question:
            do {
                bottomConstraint = (self.view.frame.height / 5 - moreInfoView.frame.height) * -1
                moreInfoView.isHidden = true
                setBackroundImage(nil)
            }
        case .info:
            do {
                bottomConstraint = (self.view.frame.height / 5 - moreInfoView.frame.height) * -1
                moreInfoView.isHidden = true
                setBackroundImage(nil)
            }
        case .suggestion:
            do {
                interactionBackOpacity = 0.3
                moreInfoView.isHidden = false
                setBackroundImage(UIImage(named: "pizza")!.alpha(0.3)) //temp pic
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
        
        for option in options {
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
    
}
