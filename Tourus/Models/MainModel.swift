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
    
    private init(){
    }
}
