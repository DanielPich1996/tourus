//
//  MainModel.swift
//  Tourus
//
//  Created by admin on 02/01/2019.
//  Copyright © 2019 Tourus. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class MainModel {
    static let instance:MainModel = MainModel()
    
    var firebaseModel = FirebaseModel();
    var sqlModel = SqlModel();
    
    private init(){
    }
   
    func signIn(_ email:String, _ password:String, _ callback:@escaping (Bool)->Void)
    {
        firebaseModel.signIn(email, password, callback)
    }
    
    func signUp(_ email:String, _ password:String, _ callback:@escaping (Bool)->Void)
    {
        firebaseModel.signUp(email, password,callback)
    }
    
    func signOut(_ callback:@escaping () -> Void) {
        firebaseModel.signOut(callback)
    }
    
    func getUserInfo(_ uid:String, callback:@escaping (UserInfo?) -> Void) {
        firebaseModel.getUserInfo(uid) { (info:UserInfo?) in
            if(info != nil) {
                var lastUpdated = UserInfo.getLastUpdateDate(database: self.sqlModel.database)
                lastUpdated += 1;
                
                UserInfo.addNew(database: self.sqlModel.database, info: info!)
                
                if (info!.timestamp > lastUpdated) {
                    lastUpdated = info!.timestamp
                    UserInfo.setLastUpdateDate(database: self.sqlModel.database, date: lastUpdated)
                    self.getUserInfoFromLocalAndNotify(uid, callback)
                }
            }
        }
        
        getUserInfoFromLocalAndNotify(uid, callback)
    }
    
    private func getUserInfoFromLocalAndNotify(_ uid:String, _ callback:@escaping (UserInfo?) -> Void) {
        let info = UserInfo.get(database: self.sqlModel.database, userId: uid)
        if(info != nil) {
            callback(info)
            NotificationModel.userInfoNotification.notify(data: info!)
        }
    }
    
    func getImage(_ url:String, _ callback:@escaping (UIImage?)->Void){
        //1. try to get the image from local store
        let _url = URL(string: url)
        let localImageName = _url!.lastPathComponent
        if let image = self.getImageFromFile(name: localImageName){
            callback(image)
            print("got image from cache \(localImageName)")
        }else{
            //2. get the image from Firebase
            firebaseModel.getImage(url){(image:UIImage?) in
                if (image != nil){
                    //3. save the image localy
                    self.saveImageToFile(image: image!, name: localImageName)
                }
                //4. return the image to the user
                callback(image)
                print("got image from firebase \(localImageName)")
            }
        }
    }
    
    func saveImageToFile(image:UIImage, name:String){
        if let data = image.jpegData(compressionQuality: 0.8) {
            let filename = getDocumentsDirectory().appendingPathComponent(name)
            try? data.write(to: filename)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in:
            .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func getImageFromFile(name:String)->UIImage?{
        let filename = getDocumentsDirectory().appendingPathComponent(name)
        return UIImage(contentsOfFile:filename.path)
    }
    
    func currentUser() -> User? {
        return firebaseModel.currentUser()
    }
}
