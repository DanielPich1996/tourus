//
//  Question.swift
//  Tourus
//
//  Created by admin on 16/03/2019.
//  Copyright © 2019 Tourus. All rights reserved.
//

import Foundation

class PlaceQuestion {
    let questionType : String
    let category : String
    var answers : [String:String]
    let question : String
    
    init(_questionType : String, _category : String, _answers : [String], _question : String) {
        questionType = _questionType
        category = _category
        //answers = _answers
        question = _question
        answers=[String:String]()
    }
    
    init(_category:String, json:[String:Any]) {
        category = _category
        question = json["question"] as! String
        questionType = json["questionType"] as! String
        answers=[String:String]()

        //let offersTmp = (json["answers"] as! String).split(separator: ",")
        //for answer in offersTmp {
         //   answers.append(String(answer))
        //}
    }
    
    func toJson() -> [String:Any] {
        var json = [String:Any]()
        
        json["category"] = category
        json["question"] = question
        json["questionType"] = questionType
        
        //var answersStr = ""
        //for answer in answers {
        //    answersStr = "\(answersStr),\(answer)"
        //}
        //json["answers"] = answersStr
        
        return json
    }
}
