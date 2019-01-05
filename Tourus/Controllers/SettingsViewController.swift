//
//  SettingsViewController.swift
//  Tourus
//
//  Created by admin on 05/01/2019.
//  Copyright © 2019 Tourus. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var userNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.clipsToBounds = true
        profileImage.layer.borderWidth = 2.0
        profileImage.layer.borderColor = UIColor.white.cgColor
        
        let image = UIImage(named: "default_profile")
        profileImage.image = image
        
        if let user = MainModel.instance.currentUser() {
            MainModel.instance.getUserInfo(user.uid, callback: { (info) in
                if info != nil {
                    self.userNameLabel.text = info?.displayName
                    
                    if info?.profileImageUrl != "" {
                        MainModel.instance.getImage(info!.profileImageUrl!) { (image:UIImage?) in
                            if image != nil {
                                self.profileImage.image = image
                            }
                        }
                    }
                }
            })
        }
    }
    
    @IBAction func onSignoutTap(_ sender: Any) {
        //Create the alert controller and actions
        let alert = UIAlertController(title: "Log Out", message: "That's it?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Log Out", style: .destructive) { _ in
            DispatchQueue.main.async {
                MainModel.instance.signOut() {() in
                    let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                    guard let loginVC = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else {
                        return
                    }
                    self.present(loginVC, animated: true, completion: nil)
                }
            }
        }
        
        //Add the actions to the alert controller
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        
        //Present the alert controller
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onBackTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
