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

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var preferencesTableView: UITableView!
    @IBOutlet var preferencesButton: UIButton!

    var selectedcells = [String]()
    var tableViewData = [cellData]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImage(named: "default_profile")
        profileImage.image = image
        
        MainModel.instance.getAllCategories() { categories in
            
            for category in categories {
                
                let displayName = category.replacingOccurrences(of: "_", with: " ").capitalized
                let data = cellData(category: category, displayCategory: displayName)
                self.tableViewData.append(data)
            }
            
            
            MainModel.instance.getAllCategories() { categories in
                
                self.selectedcells = categories
            }
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
        
        //save selectedells to firebase
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
    
}
