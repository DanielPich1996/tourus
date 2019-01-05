//
//  SqlModel.swift
//  Tourus
//
//  Created by admin on 02/01/2019.
//  Copyright © 2019 Tourus. All rights reserved.
//

import Foundation
import SQLite3

class SqlModel {
    var database: OpaquePointer? = nil
    
    init() {
        // initialize the DB
        let dbFileName = "tourus_database.db"
        if let dir = FileManager.default.urls(for: .documentDirectory, in:
            .userDomainMask).first{
            let path = dir.appendingPathComponent(dbFileName)
            if sqlite3_open(path.absoluteString, &database) != SQLITE_OK {
                print("Failed to open db file: \(path.absoluteString)")
                return
            }
            //dropTables()
            createTables()
        }
    }
    
    func createTables() {
        UserInfo.createTable(database: database);
        LastUpdateSplDates.createTable(database: database);
    }
    
    func dropTables() {
        UserInfo.drop(database: database);
        LastUpdateSplDates.drop(database: database);
    }
}




