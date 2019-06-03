//
//  PreferencesSqlExtension.swift
//  Tourus
//
//  Created by admin on 03/06/2019.
//  Copyright © 2019 Tourus. All rights reserved.
//

import Foundation
import SQLite3

extension Settings {
    
    static func createPreferencesTable(database: OpaquePointer?)  {
        var errormsg: UnsafeMutablePointer<Int8>? = nil
        let res = sqlite3_exec(database, "CREATE TABLE IF NOT EXISTS PREFERENCES (UID TEXT, CATEGORY TEXT)", nil, nil, &errormsg);
        if(res != 0){
            print("error creating PREFERENCES table");
            return
        }
    }
    
    static func dropPreferencesTable(database: OpaquePointer?)  {
        var errormsg: UnsafeMutablePointer<Int8>? = nil
        let res = sqlite3_exec(database, "DROP TABLE PREFERENCES;", nil, nil, &errormsg);
        if(res != 0){
            print("error droping PREFERENCES table");
            return
        }
    }
    
    static func getPreferences(database: OpaquePointer?, uid:String) -> [String] {
        
        var sqlite3_stmt: OpaquePointer? = nil
        let query = "SELECT CATEGORY from PREFERENCES where UID = '" + uid + "' ;"
        var categories = [String]()
        
        if (sqlite3_prepare_v2(database,query,-1,&sqlite3_stmt,nil)
            == SQLITE_OK){
            
            var sq = sqlite3_step(sqlite3_stmt)
            while(sq == SQLITE_ROW) {
                let category = String(cString:sqlite3_column_text(sqlite3_stmt,0)!)
                categories.append(category)
                
                sq = sqlite3_step(sqlite3_stmt)
            }
        }
        sqlite3_finalize(sqlite3_stmt)
        
        let minPreferences = consts.settings.minUserPreferences
        if categories.count <  minPreferences {
            categories = Interaction.getCategories(database: database)
        }
        
        let notMapped = consts.settings.notMapped
        categories.removeAll{ notMapped.contains($0) }

        return categories
    }
    
    static func addNewPreference(database: OpaquePointer?, uid:String, category:String) {
        
        var sqlite3_stmt: OpaquePointer? = nil
        
        if (sqlite3_prepare_v2(database,"INSERT OR REPLACE INTO PREFERENCES(UID, CATEGORY) VALUES (?,?);",-1, &sqlite3_stmt,nil) == SQLITE_OK) {
            
            let id = uid.cString(using: .utf8)
            let preCategory = category.cString(using: .utf8)
            
            sqlite3_bind_text(sqlite3_stmt, 1, id,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 2, preCategory,-1,nil);
            
            if(sqlite3_step(sqlite3_stmt) == SQLITE_DONE){
                print("new PREFERENCE added succefully")
            }
        }
    }
    
    static func updateUserPreferences(database: OpaquePointer?, uid:String, categories:[String]) {
        
        self.removeAllPreferences(database: database, uid: uid)
        for category in categories {
            self.addNewPreference(database: database, uid: uid, category: category)
        }
        
        print("user PREFERENCES was updated succefully")
    }
    
    static func removeAllPreferences(database: OpaquePointer?, uid:String) {
        var sqlite3_stmt: OpaquePointer? = nil
        
        let query = "DELETE FROM PREFERENCES where UID = '" + uid + "' ;"
        if (sqlite3_prepare_v2(database,query,-1, &sqlite3_stmt,nil) == SQLITE_OK) {
            if(sqlite3_step(sqlite3_stmt) == SQLITE_DONE){
                print("PREFERENCES was deleted succefully")
            }
        }
    }
}
