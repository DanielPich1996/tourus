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
  
        updateUserHistory("zoo" ,1)
    }
    
    
    func getAllInteractionsFromDate(from:Double, callback:@escaping ([Interaction])->Void) {        
        let stRef = databaseRef.child(consts.names.interactionsTableName)
        let fbQuery = stRef.queryOrdered(byChild: "lastUpdate").queryStarting(atValue: from)
        fbQuery.observe(.value) { (snapshot) in
            
            var data = [Interaction]()

            if let value = snapshot.value as? [String : Any] {
                for (id, json) in value {
                    data.append(Interaction(_id: id, json: json as! [String : Any]))
                }
            }
            
            callback(data)
        }
    }
    
    func getAllOptionsFromDate(from:Double, callback:@escaping ([Interaction.Option])->Void) {
        let stRef = databaseRef.child(consts.names.optionsTableName)
        let fbQuery = stRef.queryOrdered(byChild: "lastUpdate").queryStarting(atValue: from)
        fbQuery.observe(.value) { (snapshot) in
            
            var data = [Interaction.Option]()
            
            if let value = snapshot.value as? [String : Any] {
                for (type, json) in value {
                    if let inner_value = json as? [String : Any] {
                        for (key, text) in inner_value {
                            if text is String {
                                data.append(Interaction.Option(_id: key, type, text as! String))
                            }
                        }
                    }
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
    
    func getAllUsersHistory(_ callback: @escaping ([String : [String : Double]]?) -> Void){
        // Gets all users history, the [String : Double] part should look just like in getCurrentUserHistory
        // and the String that comes along with each [String : Double] should be the user's email
        
        let stub = ["Joe@gmail.com" : ["cafe" : 3.0 , "food" : 2.0 , "movie" : 4.0],
                    "Misha@gmail.com" : ["cafe" : 2.0 , "food" : 5.0 , "movie" : 3.0],
                    "Alice@gmail.com" : ["casino" : 3.0 , "food" : 2.0 , "movie" : 4.0],
                    "Greg@gmail.com" : ["cafe" : 3.0 , "casino" : 2.0 , "movie" : 4.0]]
        
        callback(stub)
    }
    
    func getCurrentUserHistory(_ callback:@escaping ([String : Double]?) -> Void) {
        let user = currentUser()
       
        if(user != nil){
        self.databaseRef!.child(consts.names.userInfoTableName).child(user!.uid).child("History").observe(.value){ (snapshot)       in
                if snapshot.exists() {
                    if let value = snapshot.value as? [String : Double]{
                    callback(value)
                    }
                }
                else {
                    callback(nil)
                }
            }
        }
    }
    func updateUserHistory(_ category:String ,_ addedvalue:Double) {
        let user = currentUser()
       
        if(user != nil) {
        let db = self.databaseRef!.child(consts.names.userInfoTableName).child(user!.uid).child("History").child(category)
        
            //fix- check if the category exists
            db.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                if let value = snapshot.value as? Double {
                    db.setValue(value + addedvalue)
                }
            }
            
            
        })
    }
    
    }
    

}
