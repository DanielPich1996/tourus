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
            //dropTables()
            createTables()
    }
    
    func createTables() {
    }
    
    func dropTables() {
    }
}




