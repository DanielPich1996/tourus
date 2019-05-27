//
//  SettingsViewController.swift
//  Tourus
//
//  Created by admin on 05/01/2019.
//  Copyright © 2019 Tourus. All rights reserved.
//

import UIKit

struct cellData{
    var opened = Bool()
    var title = String()
    var sectionData = [String]()
    
    
}

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
      //  var selectIndexPath: IndexPath!
    var selectedcells = [String]()
    var tableViewData = [cellData(opened: false, title: "Choose", sectionData:["a","b","c","d"])]
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewData.count
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableViewData[section].opened == true {
            return tableViewData[section].sectionData.count + 1
        }
        else{
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let dataIndex = indexPath.row - 1
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {return UITableViewCell()}
        
        if indexPath.row == 0 {
            cell.textLabel?.text = tableViewData[indexPath.section].title
        }
        else {
            cell.textLabel?.text = tableViewData[indexPath.section].sectionData[dataIndex]
            //cell.accessoryType = .checkmark
        }
        
        return cell
    }


    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        // store titles of selected cells to selectedcells
        let nowCell = tableView.cellForRow(at: indexPath)
        let nowCellTitle = nowCell?.textLabel?.text
        var titleRepeat = false
        var showMark = false
        
        if(nowCellTitle != "Choose" && titleRepeat == false){
            for a in selectedcells{
                if (a ==  nowCellTitle){
                    titleRepeat = true
                }
            }
            if (titleRepeat == false){
                self.selectedcells.append(nowCellTitle!)
//                for n in selectedcells {
//                    print(n)
//                }
            }
        }
        //
        //let tmp = indexPath.row
        
        if indexPath.row == 0{
            if tableViewData[indexPath.section].opened == true {
                tableViewData[indexPath.section].opened = false
                let sections = IndexSet.init(integer: indexPath.section)
                tableView.reloadSections(sections, with: .none)
            }
            else {
                tableViewData[indexPath.section].opened = true
                let sections = IndexSet.init(integer: indexPath.section)
                tableView.reloadSections(sections, with: .none)
            }
        }
        else {
            for b in selectedcells{
                if nowCellTitle == b {
                    showMark = true
                }
            }
            
            if nowCell?.accessoryType == UITableViewCell.AccessoryType.checkmark {
                nowCell?.accessoryType = UITableViewCell.AccessoryType.none
            }
            else if showMark == true {
                //tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.checkmark
                nowCell?.accessoryType = UITableViewCell.AccessoryType.checkmark
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeSelectRowAt indexPath: IndexPath){
        // store titles of selected cells to selectedcells
        let nowCell = tableView.cellForRow(at: indexPath)
        let nowCellTitle = nowCell?.textLabel?.text
        var titleRepeat = false
        
        if(nowCellTitle != "Choose" && titleRepeat == false){
            for a in selectedcells{
                if (a ==  nowCellTitle){
                    titleRepeat = true
                }
            }
            if (titleRepeat == true){
                //To Do
                
                
                //self.selectedcells.remove(at: 0)
                //                for n in selectedcells {
                //                    print(n)
                //                }
            }
        }
        //
        //let tmp = indexPath.row
        
        
    }
    
    
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

