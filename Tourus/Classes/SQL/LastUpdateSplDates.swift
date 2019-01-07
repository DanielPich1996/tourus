//
//  LastUpdateSplDates.swift
//  Tourus
//
//  Created by admin on 05/01/2019.
//  Copyright © 2019 Tourus. All rights reserved.
//

import Foundation
import SQLite3

class LastUpdateSplDates {
    static func createTable(database: OpaquePointer?) {
        var errormsg: UnsafeMutablePointer<Int8>? = nil
        let res = sqlite3_exec(database, "CREATE TABLE IF NOT EXISTS LAST_UPDATE (TABLE_NAME TEXT PRIMARY KEY, DATE DOUBLE)", nil, nil, &errormsg);
        if(res != 0){
            print("error creating table");
            return
        }
    }
    
    static func drop(database: OpaquePointer?) {
        var errormsg: UnsafeMutablePointer<Int8>? = nil
        let res = sqlite3_exec(database, "DROP TABLE LAST_UPDATE;", nil, nil, &errormsg);
        if(res != 0){
            print("error creating table");
            return
        }
    }
    
    static func get(database: OpaquePointer?, tabeName:String) -> Double {
        var sqlite3_stmt: OpaquePointer? = nil
        var lud:Double = 0
        if (sqlite3_prepare_v2(database,"SELECT DATE from LAST_UPDATE where TABLE_NAME = ? ;",-1,&sqlite3_stmt,nil)
            == SQLITE_OK){
            sqlite3_bind_text(sqlite3_stmt, 1, tabeName,-1,nil);
            
            if(sqlite3_step(sqlite3_stmt) == SQLITE_ROW){
                lud = sqlite3_column_double(sqlite3_stmt,0)
            }
        }
        sqlite3_finalize(sqlite3_stmt)
        return lud
    }
    
    static func set(database: OpaquePointer?, tableName:String, date:Double) {
        var sqlite3_stmt: OpaquePointer? = nil
        if (sqlite3_prepare_v2(database,"INSERT OR REPLACE INTO LAST_UPDATE(TABLE_NAME, DATE) VALUES (?,?);",-1, &sqlite3_stmt,nil) == SQLITE_OK){
            let name = tableName.cString(using: .utf8)
            sqlite3_bind_text(sqlite3_stmt, 1, name,-1,nil);
            sqlite3_bind_double(sqlite3_stmt, 2, date);
            if(sqlite3_step(sqlite3_stmt) == SQLITE_DONE){
                print("new row added succefully")
            }
        }
        sqlite3_finalize(sqlite3_stmt)
    }
}

