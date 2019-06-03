//
//  InteractionSqlExtension.swift
//  Tourus
//
//  Created by admin on 18/03/2019.
//  Copyright © 2019 Tourus. All rights reserved.
//

import Foundation
import SQLite3

extension Interaction {
    
    static func createTable(database: OpaquePointer?)  {
        var errormsg: UnsafeMutablePointer<Int8>? = nil
        let res = sqlite3_exec(database, "CREATE TABLE IF NOT EXISTS INTERACTION (ID TEXT PRIMARY KEY, TYPE TEXT, TEXT TEXT, CATEGORY TEXT, LAST_UPDATE DOUBLE, OPTIONS TEXT)", nil, nil, &errormsg);
        if(res != 0){
            print("error creating table INTERACTION");
            return
        }
    }
    
    static func drop(database: OpaquePointer?)  {
        var errormsg: UnsafeMutablePointer<Int8>? = nil
        let res = sqlite3_exec(database, "DROP TABLE INTERACTION;", nil, nil, &errormsg);
        if(res != 0){
            print("error dropping table INTERACTION");
            return
        }
    }
    
    static func get(database: OpaquePointer?, category:String? = nil)-> Interaction? {
        var sqlite3_stmt: OpaquePointer? = nil
        
        var query = "SELECT ID, TYPE, TEXT, CATEGORY, LAST_UPDATE, OPTIONS from INTERACTION ORDER BY RANDOM() LIMIT 1"
        if(category != nil) {
            query = "SELECT ID, TYPE, TEXT, CATEGORY, LAST_UPDATE, OPTIONS from INTERACTION where CATEGORY = '" + category! + "' ORDER BY RANDOM() LIMIT 1"
        }
        
        var info:Interaction? = nil
        if (sqlite3_prepare_v2(database,query,-1,&sqlite3_stmt,nil)
            == SQLITE_OK){
            
            if(sqlite3_step(sqlite3_stmt) == SQLITE_ROW){
                let id = String(cString:sqlite3_column_text(sqlite3_stmt,0)!)
                let type = String(cString:sqlite3_column_text(sqlite3_stmt,1)!)
                let text = String(cString:sqlite3_column_text(sqlite3_stmt,2)!)
                let category = String(cString:sqlite3_column_text(sqlite3_stmt,3)!)
                let lastUpdate:Double = sqlite3_column_double(sqlite3_stmt,4)
                let options_string = String(cString:sqlite3_column_text(sqlite3_stmt,5)!)

                let splited_options:[String] = options_string.components(separatedBy: "&&")
                var options = [Option]()

                //expected format: "type||text&&type2||text2"
                for option in splited_options {
                    let option_data:[String] = option.components(separatedBy: "||")
                    if(option_data.count == 2) {
                        var text:String = option_data[1]
                        if(option_data[1] == "") {
                            text = Interaction.Option.get(database: database, type: option_data[0])?.text ?? ""
                        }
                        options.append(Interaction.Option(option_data[0], text))
                    }
                    else {
                        print("option don't have the expected args count")
                    }
                }
                
                info = Interaction(id, 0, type, text, options, category, lastUpdate)
            }
        }
        
        sqlite3_finalize(sqlite3_stmt)
        return info
    }
    
    static func getCategories(database: OpaquePointer?) -> [String] {
        var sqlite3_stmt: OpaquePointer? = nil
        var categories = [String]()
        
        let query = "SELECT DISTINCT CATEGORY from INTERACTION"
       
        if (sqlite3_prepare_v2(database,query,-1,&sqlite3_stmt,nil)
            == SQLITE_OK){
            
            while(sqlite3_step(sqlite3_stmt) == SQLITE_ROW) {
                
                let category = String(cString:sqlite3_column_text(sqlite3_stmt,0)!)
                categories.append(category)
            }
        }
        sqlite3_finalize(sqlite3_stmt)
        
        let notMapped = consts.settings.notMapped
        categories.removeAll{ notMapped.contains($0) }

        return categories
    }
    
    
    static func addNew(database: OpaquePointer?, interaction:Interaction) {
        var sqlite3_stmt: OpaquePointer? = nil
        if (sqlite3_prepare_v2(database,"INSERT OR REPLACE INTO INTERACTION(ID, TYPE, TEXT, CATEGORY, LAST_UPDATE, OPTIONS) VALUES (?,?,?,?,?,?);",-1, &sqlite3_stmt,nil) == SQLITE_OK) {

            let id = interaction.id.cString(using: .utf8)
            let type = interaction.type.rawValue.cString(using: .utf8)
            let text = interaction.text.cString(using: .utf8)
            let category = interaction.category.cString(using: .utf8)
            let lastUpdate = interaction.lastUpdate
            
            var options_string = ""
            for (idx, option) in interaction.options.enumerated() {
                options_string.append(option.toString())

                //add '&&' if the current item isn't the last in the array
                if idx != interaction.options.endIndex-1 {
                   options_string.append("&&")
                }
            }
            let options = options_string.cString(using: .utf8)
            
            sqlite3_bind_text(sqlite3_stmt, 1, id,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 2, type,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 3, text,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 4, category,-1,nil);
            sqlite3_bind_double(sqlite3_stmt, 5, lastUpdate);
            sqlite3_bind_text(sqlite3_stmt, 6, options,-1,nil);

            if(sqlite3_step(sqlite3_stmt) == SQLITE_DONE){
                print("new interaction row added succefully")
            }
        }
    }
    
    static func delete(database: OpaquePointer?, id:String) {
        var sqlite3_stmt: OpaquePointer? = nil
        let query = "DELETE FROM INTERACTION WHERE ID = '" + id + "' ;"
        
        if (sqlite3_prepare_v2(database,query,-1, &sqlite3_stmt,nil) == SQLITE_OK){
            if sqlite3_step(sqlite3_stmt) == SQLITE_DONE {
                print("Successfully deleted interaction row.")
            } else {
                print("Could not delete interaction row.")
            }
        } else {
            print("DELETE statement could not be prepared for interaction")
        }
    }
    
    static func getLastUpdateDate(database: OpaquePointer?)->Double{
        return LastUpdateSplDates.get(database: database, tabeName: "INTERACTION")
    }
    
    static func setLastUpdateDate(database: OpaquePointer?, date:Double){
        LastUpdateSplDates.set(database: database, tableName: "INTERACTION", date: date);
    }
}

