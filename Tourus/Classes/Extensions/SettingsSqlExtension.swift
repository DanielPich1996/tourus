//
//  SettingsSqlExtension.swift
//  Tourus
//
//  Created by admin on 01/06/2019.
//  Copyright © 2019 Tourus. All rights reserved.
//

import Foundation
import SQLite3

extension Settings {
    
    static func createTable(database: OpaquePointer?)  {
        var errormsg: UnsafeMutablePointer<Int8>? = nil
        let res = sqlite3_exec(database, "CREATE TABLE IF NOT EXISTS SETTINGS (UID TEXT PRIMARY KEY, IS_DIRECTIONAL_AUDIO_ON INT)", nil, nil, &errormsg);
        if(res != 0){
            print("error creating table");
            return
        }
    }
    
    static func drop(database: OpaquePointer?)  {
        var errormsg: UnsafeMutablePointer<Int8>? = nil
        let res = sqlite3_exec(database, "DROP TABLE SETTINGS;", nil, nil, &errormsg);
        if(res != 0){
            print("error creating table");
            return
        }
    }
    
    static func get(database: OpaquePointer?, userId:String) -> Settings? {
        
        let directionalAudioOn = self.getIsNavigationAudioOn(database: database, userId: userId)
        let preferences = self.getPreferences(database: database, uid: userId)
        
        return Settings(userId, directionalAudioOn, preferences)
    }
    
    static func getIsNavigationAudioOn(database: OpaquePointer?, userId:String) -> Bool {
        var sqlite3_stmt: OpaquePointer? = nil
        let query = "SELECT UID, IS_DIRECTIONAL_AUDIO_ON from SETTINGS where UID = '" + userId + "' ;"
        var directionalAudioOnBoolFromat:Bool = true
        
        if (sqlite3_prepare_v2(database,query,-1,&sqlite3_stmt,nil)
            == SQLITE_OK){
            
            if(sqlite3_step(sqlite3_stmt) == SQLITE_ROW){
                
                let directionalAudioOn:Int32 = sqlite3_column_int(sqlite3_stmt,1)
                directionalAudioOnBoolFromat = (directionalAudioOn==1)
            }
        }
        
        sqlite3_finalize(sqlite3_stmt)
        return directionalAudioOnBoolFromat
    }
    
    static func addNew(database: OpaquePointer?, settings:Settings) {
        var sqlite3_stmt: OpaquePointer? = nil
        
        if (sqlite3_prepare_v2(database,"INSERT OR REPLACE INTO SETTINGS(UID, IS_DIRECTIONAL_AUDIO_ON) VALUES (?,?);",-1, &sqlite3_stmt,nil) == SQLITE_OK){
            
            let uid = settings.uid.cString(using: .utf8)
            var directionalAudioOn:Int32 = 0
            if settings.isDirectionalAudioOn {
                directionalAudioOn = 1
            }
            
            sqlite3_bind_text(sqlite3_stmt, 1, uid,-1,nil);
            sqlite3_bind_int(sqlite3_stmt, 2, directionalAudioOn);
            
            if(sqlite3_step(sqlite3_stmt) == SQLITE_DONE){
                print("new row added succefully")
            }
        }
        
        if let preferences = settings.preferencesCategories {
            self.updateUserPreferences(database: database, uid: settings.uid, categories: preferences)
        }
    }
}


