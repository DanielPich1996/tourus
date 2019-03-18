//
//  Question.swift
//  Tourus
//
//  Created by admin on 16/03/2019.
//  Copyright © 2019 Tourus. All rights reserved.
//

import Foundation

class Question {
    let questionType : String
    let category : String
    var offers = [String]()
    let question : String
    
    init(_questionType : String, _category : String, _offers : [String], _question : String) {
        questionType = _questionType
        category = _category
        offers = _offers
        question = _question
    }
    
    init(_category:String, json:[String:Any]) {
        category = _category
        question = json["question"] as! String
        questionType = json["questionType"] as! String
        
        let offersTmp = (json["offers"] as! String).split(separator: ",")
        for offer in offersTmp {
            offers.append(String(offer))
        }
    }
    
    func toJson() -> [String:Any] {
        var json = [String:Any]()
        
        json["category"] = category
        json["question"] = question
        json["questionType"] = questionType
        
        var offerStr = ""
        for offer in offers {
            offerStr = "\(offerStr),\(offer)"
        }
        json["offers"] = offerStr
        
        return json
    }
}
