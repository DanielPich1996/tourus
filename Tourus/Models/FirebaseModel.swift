//
//  FirebaseModel.swift
//  Tourus
//
//  Created by admin on 02/01/2019.
//  Copyright © 2019 Tourus. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import UIKit

class FirebaseModel {
    var databaseRef: DatabaseReference!
    lazy var storageRef = Storage.storage().reference(forURL:
        "gs://org-tourus-acb4d.appspot.com")
    
    init() {
        FirebaseApp.configure()
        databaseRef = Database.database().reference()
        
        self.databaseRef!.child("fff").setValue("gg")       
    }
    
    func addInteraction(_ interaction:Interaction) {
      self.databaseRef!.child(consts.names.interactionsTableName).child("1").setValue(interaction.toJson())
    }
    
    func getAllInteractionsFromDate(from:Double, callback:@escaping ([Interaction])->Void) {
        let stRef = databaseRef.child(consts.names.interactionsTableName)
        let fbQuery = stRef.queryOrdered(byChild: "lastUpdate").queryStarting(atValue: from)
        fbQuery.observe(.value) { (snapshot) in
            var data = [Interaction]()
            if let value = snapshot.value as? [String:Any] {
                for (_, json) in value{
                    data.append(Interaction(json: json as! [String : Any]))
                }
            }
            callback(data)
        }
    }
    
    //MARK:- UserFunctons
    
    func addUserInfo(_ userInfo:UserInfo, _ image:UIImage?, _ completionBlock:@escaping (Bool) -> Void = {_  in}) {
        if image != nil {
            saveImage(folderName: consts.names.profileImagesFolderName, image: image!) { (url:String?) in
                if url != nil {
                    userInfo.profileImageUrl = url!
                }
                self.databaseRef!.child(consts.names.userInfoTableName).child(userInfo.uid).setValue(userInfo.toJson())
                completionBlock(true)
            }
        }
        else {
            self.databaseRef!.child(consts.names.userInfoTableName).child(userInfo.uid).setValue(userInfo.toJson())
            completionBlock(true)
        }
    }
    
    func saveImage(folderName:String, image:UIImage, callback:@escaping (String?) -> Void) {
        let data = image.jpegData(compressionQuality: 0.8)
        let imageName = "\(Date().timeIntervalSince1970).jpg"
        let imageRef = storageRef.child(folderName).child(imageName)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        imageRef.putData(data!, metadata: metadata) { (metadata, error) in
            imageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    return
                }
                print("url: \(downloadURL)")
                callback(downloadURL.absoluteString)
            }
        }
    }
    
    func getImage(_ url:String, _ callback:@escaping (UIImage?) -> Void) {
        let ref = Storage.storage().reference(forURL: url)
        ref.getData(maxSize: 10 * 1024 * 1024) { data, error in
            if error != nil {
                callback(nil)
            } else {
                let image = UIImage(data: data!)
                callback(image)
            }
        }
    }
    
    func getUserInfo(_ uid:String, callback:@escaping (UserInfo?) -> Void) {
        self.databaseRef!.child(consts.names.userInfoTableName).child(uid).observeSingleEvent(of: .value, with: {
            (snapshot) in
            
            if snapshot.exists() {
                let value = snapshot.value as! [String:Any]
                let userInfo = UserInfo(_uid: uid, json: value)
                
                callback(userInfo)
            }
            else {
                callback(nil)
            }
        })
    }    
    
    func signUp(_ email:String, _ password:String, _ callback:@escaping (Bool) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if authResult?.user != nil {
                
                let email = authResult!.user.email!
                let display = (email.components(separatedBy: "@"))[0]
                
                let userInfo = UserInfo(_uid: authResult!.user.uid, _displayName: display, _email: email, _profileImageUrl: nil)
                self.addUserInfo(userInfo, nil, { (val) in
                    callback(true)
                })
            }
            else {
                callback(false)
            }
        }
    }
    
    func signIn(_ email:String, _ password:String, _ callback:@escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if (user != nil  ) {
                callback(true)
            }
            else {
                callback(false)
            }
        }
    }
    
    func signOut(_ callback:@escaping () -> Void) {
        do {
            try Auth.auth().signOut()
            callback()
        } catch {
            print("Error while signing out!")
        }
    }
    
    func currentUser() -> User? {
        return Auth.auth().currentUser
    }
    
    //MARK:- AttractionFunctons
    
    func getAttraction(_ uid:String, callback:@escaping (Attraction?) -> Void) {
        self.databaseRef!.child(consts.names.attractionsTableName).child(uid).observeSingleEvent(of: .value, with: {
            (snapshot) in
            
            if snapshot.exists() {
                let value = snapshot.value as! [String:Any]
                let attraction = Attraction(_uid: uid, json: value)
                
                callback(attraction)
            }
            else {
                callback(nil)
            }
        })
    }
    
    func setAttraction(_ attraction:Attraction, _ completionBlock:@escaping (Bool) -> Void = {_  in}) {
        self.databaseRef!.child(consts.names.attractionsTableName).child(attraction.uid).setValue(attraction.toJson()){
            (error:Error?, ref:DatabaseReference) in
            if error != nil {
                completionBlock(false)
            } else {
                completionBlock(true)
            }
        }
    }
    
    //MARK:- CategoryFunctons
    
    func getAllCaregories(callback:@escaping (Category?) -> Void) {
        self.databaseRef!.child(consts.names.categoriesTableName).observeSingleEvent(of: .value, with: {
            (snapshot) in
            
            if snapshot.exists() {
                let value = snapshot.value as! [String:Any]
                let categories = Category(_mainCategory: "", json: value)
                
                callback(categories)
            }
            else {
                callback(nil)
            }
        })
    }
    
    func setCategory(_ category:Category, _ completionBlock:@escaping (Bool) -> Void = {_  in}) {
        self.databaseRef!.child(consts.names.categoriesTableName).child(category.mainCategory).setValue(category.toJson()){
            (error:Error?, ref:DatabaseReference) in
            if error != nil {
                completionBlock(false)
            } else {
                completionBlock(true)
            }
        }
    }
    
}

