//
//  UserInfoSqlExtension.swift
//  Tourus
//
//  Created by admin on 05/01/2019.
//  Copyright © 2019 Tourus. All rights reserved.
//

import Foundation
import SQLite3

extension UserInfo {
    
    static func createTable(database: OpaquePointer?)  {
        var errormsg: UnsafeMutablePointer<Int8>? = nil
        let res = sqlite3_exec(database, "CREATE TABLE IF NOT EXISTS USER_INFO (UID TEXT PRIMARY KEY, DISPLAY_NAME TEXT, EMAIL TEXT, IMAGEURL TEXT, TIMESTAMP DOUBLE)", nil, nil, &errormsg);
        if(res != 0){
            print("error creating table");
            return
        }
    }
    
    static func drop(database: OpaquePointer?)  {
        var errormsg: UnsafeMutablePointer<Int8>? = nil
        let res = sqlite3_exec(database, "DROP TABLE USER_INFO;", nil, nil, &errormsg);
        if(res != 0){
            print("error creating table");
            return
        }
    }
    
    static func get(database: OpaquePointer?, userId:String)-> UserInfo? {
        var sqlite3_stmt: OpaquePointer? = nil
        let query = "SELECT UID, DISPLAY_NAME, EMAIL, IMAGEURL, TIMESTAMP from USER_INFO where UID = '" + userId + "' ;"
        var info:UserInfo? = nil
        if (sqlite3_prepare_v2(database,query,-1,&sqlite3_stmt,nil)
            == SQLITE_OK){
            
            if(sqlite3_step(sqlite3_stmt) == SQLITE_ROW){
                let uid = String(cString:sqlite3_column_text(sqlite3_stmt,0)!)
                let displayName = String(cString:sqlite3_column_text(sqlite3_stmt,1)!)
                let email = String(cString:sqlite3_column_text(sqlite3_stmt,2)!)
                let imageUrl = String(cString:sqlite3_column_text(sqlite3_stmt,3)!)
                let timestamp:Double = sqlite3_column_double(sqlite3_stmt,4)
                
                info = UserInfo(_uid: uid, _displayName: displayName, _email: email, _profileImageUrl: imageUrl, _timestamp: timestamp)
            }
        }
        
        sqlite3_finalize(sqlite3_stmt)
        return info
    }
    
    static func addNew(database: OpaquePointer?, info:UserInfo) {
        var sqlite3_stmt: OpaquePointer? = nil
        if (sqlite3_prepare_v2(database,"INSERT OR REPLACE INTO USER_INFO(UID, DISPLAY_NAME, EMAIL, IMAGEURL, TIMESTAMP) VALUES (?,?,?,?,?);",-1, &sqlite3_stmt,nil) == SQLITE_OK){
            let uid = info.uid.cString(using: .utf8)
            let displayName = info.displayName.cString(using: .utf8)
            let email = info.email.cString(using: .utf8)
            let imageUrl = info.profileImageUrl?.cString(using: .utf8)
            let timestamp = info.timestamp
            
            sqlite3_bind_text(sqlite3_stmt, 1, uid,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 2, displayName,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 3, email,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 4, imageUrl,-1,nil);
            sqlite3_bind_double(sqlite3_stmt, 5, timestamp);
            
            if(sqlite3_step(sqlite3_stmt) == SQLITE_DONE){
                print("new row added succefully")
            }
        }
    }
    
    static func getLastUpdateDate(database: OpaquePointer?)->Double{
        return LastUpdateSplDates.get(database: database, tabeName: "USER_INFO")
    }
    
    static func setLastUpdateDate(database: OpaquePointer?, date:Double){
        LastUpdateSplDates.set(database: database, tableName: "USER_INFO", date: date);
    }
}

