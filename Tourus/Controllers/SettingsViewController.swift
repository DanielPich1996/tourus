//
//  SettingsViewController.swift
//  Tourus
//
//  Created by Alice on 05/01/2019.
//  Copyright © 2019 Tourus. All rights reserved.
//

import UIKit

struct cellData{
    var category = String()
    var displayCategory = String()
}

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var preferencesTableView: UITableView!
    @IBOutlet var preferencesButton: UIButton!
    @IBOutlet weak var directionalSwitch: UISwitch!
    
    var selectedcells = [String]()
    var tableViewData = [cellData]()
    
    
    @IBAction func onDirectionalAudioSwitchTap(_ sender: Any) {
        
        if let uid = MainModel.instance.currentUser()?.uid {
            let settings = Settings(uid, directionalSwitch.isOn)
            MainModel.instance.updateSettings(settings)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(SettingsViewController.tapDetected))
        let image = UIImage(named: "default_profile")
        profileImage.image = image
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(singleTap)

        if let settings = MainModel.instance.getSettings() {
            directionalSwitch.isOn = settings.isDirectionalAudioOn
        } else {
            directionalSwitch.isOn = true
        }
        
        MainModel.instance.getAllCategories() { categories in
            
            for category in categories {
                
                let displayName = category.replacingOccurrences(of: "_", with: " ").capitalized
                let data = cellData(category: category, displayCategory: displayName)
                self.tableViewData.append(data)
            }
        }
        
        MainModel.instance.getCurrentUserPreferences() { categories in
            self.selectedcells = categories
        }
        
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
    
    var isOpened = false
    @IBAction func onDropExpand(_ sender: Any) {
        
        isOpened = !isOpened
        if isOpened {
            let sections = IndexSet.init(integer: 0)
            preferencesTableView.reloadSections(sections, with: .none)
        }
        else {
            let sections = IndexSet.init(integer: 0)
            preferencesTableView.reloadSections(sections, with: .none)
        }
    }
    
    @IBAction func onSignoutTap(_ sender: Any) {
        //Create the alert controller and actions
        let alert = UIAlertController(title: "Log Out", message: "That's it?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Log Out", style: .destructive) { _ in
            DispatchQueue.main.async {
                
                MainModel.instance.updateUserPreferences(self.selectedcells)
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
        
        MainModel.instance.updateUserPreferences(self.selectedcells)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isOpened {
            return tableViewData.count
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:CategoryTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryTableViewCell
        
        let category = tableViewData[indexPath.row].category
        let displayCategory = tableViewData[indexPath.row].displayCategory
        let checked = selectedcells.contains(category)
        
        cell.setCellData(category, displayCategory, checked)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        // store titles of selected cells to selectedcells
        let nowCell = tableView.cellForRow(at: indexPath) as! CategoryTableViewCell
        
        if !nowCell.category.isEmpty {
            
            let categoryExists = selectedcells.contains(nowCell.category)
                
            if (!categoryExists) {
                self.selectedcells.append(nowCell.category)
            }
           
            nowCell.setCellData(nowCell.category, nowCell.displayCategory, true)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath){
        // store titles of selected cells to selectedcells
        let nowCell = tableView.cellForRow(at: indexPath) as! CategoryTableViewCell
        
        if !nowCell.category.isEmpty {
            
            let categoryExists = selectedcells.contains(nowCell.category)
                
            if (categoryExists) {
                self.selectedcells.removeAll{ $0 == nowCell.category }
            }
            
            nowCell.setCellData(nowCell.category, nowCell.displayCategory, false)
        }
    }
    
    //IMAGE
    
    @objc func tapDetected(){
        showImagePicker()
    }
    
    @objc private func showImagePicker(){
        //Creating an instance of the image picker controller and using it
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = false
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    //Closing the picker in case of a cancelation request from the user
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //If the user picked an image, wer'e grabbing the image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            BuisyIndicator.Instance.showBuisyIndicator()
            self.view.isUserInteractionEnabled = false
            
            if let user = MainModel.instance.currentUser() {
                MainModel.instance.getUserInfo(user.uid, callback: {(userInfo:UserInfo?) in
                    
                    if (userInfo != nil) {
                        MainModel.instance.updateUserInfo(userInfo!.uid, userInfo!.profileImageUrl, image, {(res:Bool) in
                            if(res == true) {
                                self.profileImage.image = image
                            } else {
                                self.present(consts.general.getCancelAlertController(title: "Profile Image", messgae: "Error while uploading the image"), animated: true)
                            }
                            
                            BuisyIndicator.Instance.hideBuisyIndicator()
                            self.view.isUserInteractionEnabled = true
                        })
                    } else {
                        self.present(consts.general.getCancelAlertController(title: "Profile Image", messgae: "Error while uploading profile image"), animated: true)
                        
                        BuisyIndicator.Instance.hideBuisyIndicator()
                        self.view.isUserInteractionEnabled = true
                    }
                })
            }
        } else {
            present(consts.general.getCancelAlertController(title: "Profile Image", messgae: "Error while selecting an image"), animated: true)
            
            BuisyIndicator.Instance.hideBuisyIndicator()
            self.view.isUserInteractionEnabled = true
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}
