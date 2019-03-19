//
//  OptionSqlExtension.swift
//  Tourus
//
//  Created by admin on 19/03/2019.
//  Copyright © 2019 Tourus. All rights reserved.
//

import Foundation
import SQLite3

extension Interaction.Option {
    
    static func createTable(database: OpaquePointer?)  {
        var errormsg: UnsafeMutablePointer<Int8>? = nil
        let res = sqlite3_exec(database, "CREATE TABLE IF NOT EXISTS OPTION (ID TEXT PRIMARY KEY, TYPE TEXT, TEXT TEXT)", nil, nil, &errormsg);
        if(res != 0){
            print("error creating table OPTION");
            return
        }
    }
    
    static func drop(database: OpaquePointer?)  {
        var errormsg: UnsafeMutablePointer<Int8>? = nil
        let res = sqlite3_exec(database, "DROP TABLE OPTION;", nil, nil, &errormsg);
        if(res != 0){
            print("error dropping table OPTION");
            return
        }
    }
    
    static func get(database: OpaquePointer?, type:String)-> Interaction.Option? {
        var sqlite3_stmt: OpaquePointer? = nil
        let query = "SELECT ID, TYPE, TEXT from OPTION where TYPE = '" + type + "' ORDER BY RANDOM() LIMIT 1"
        var info:Interaction.Option? = nil
        if (sqlite3_prepare_v2(database,query,-1,&sqlite3_stmt,nil)
            == SQLITE_OK){
            
            if(sqlite3_step(sqlite3_stmt) == SQLITE_ROW){
                let id = String(cString:sqlite3_column_text(sqlite3_stmt,0)!)
                let type = String(cString:sqlite3_column_text(sqlite3_stmt,1)!)
                let text = String(cString:sqlite3_column_text(sqlite3_stmt,2)!)
                
                info = Interaction.Option(_id: id, type, text)
            }
        }
        
        sqlite3_finalize(sqlite3_stmt)
        return info
    }
    
    static func addNew(database: OpaquePointer?, option:Interaction.Option) {
        var sqlite3_stmt: OpaquePointer? = nil
        if (sqlite3_prepare_v2(database,"INSERT OR REPLACE INTO OPTION(ID, TYPE, TEXT) VALUES (?,?,?);",-1, &sqlite3_stmt,nil) == SQLITE_OK) {
            
            let id = option.id.cString(using: .utf8)
            let type = option.type.rawValue.cString(using: .utf8)
            let text = option.text.cString(using: .utf8)
            
            sqlite3_bind_text(sqlite3_stmt, 1, id,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 2, type,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 3, text,-1,nil);
            
            if(sqlite3_step(sqlite3_stmt) == SQLITE_DONE){
                print("new OPTION row added succefully")
            }
        }
    }
    
    static func delete(database: OpaquePointer?, id:String) {
        var sqlite3_stmt: OpaquePointer? = nil
        let query = "DELETE FROM OPTION WHERE ID = '" + id + "' ;"
        
        if (sqlite3_prepare_v2(database,query,-1, &sqlite3_stmt,nil) == SQLITE_OK){
            if sqlite3_step(sqlite3_stmt) == SQLITE_DONE {
                print("Successfully deleted OPTION row.")
            } else {
                print("Could not delete OPTION row.")
            }
        } else {
            print("DELETE statement could not be prepared for OPTION")
        }
    }
    
    static func getLastUpdateDate(database: OpaquePointer?)->Double{
        return LastUpdateSplDates.get(database: database, tabeName: "OPTION")
    }
    
    static func setLastUpdateDate(database: OpaquePointer?, date:Double){
        LastUpdateSplDates.set(database: database, tableName: "OPTION", date: date);
    }
}

