//
//  Settings.swift
//  Tourus
//
//  Created by admin on 01/06/2019.
//  Copyright © 2019 Tourus. All rights reserved.
//

import Foundation

class Settings {
    
    var uid:String = ""
    var isDirectionalAudioOn:Bool = false
    var preferencesCategories:[String]? = nil
    
    init(_ uid:String, _ isDirectionalAudioOn:Bool, _ preferencesCategories:[String]? = nil) {
        
        self.uid = uid
        self.isDirectionalAudioOn = isDirectionalAudioOn
        self.preferencesCategories = preferencesCategories
    }
}
