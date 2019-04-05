//
//  Interaction.swift
//  Tourus
//
//  Created by admin on 07/01/2019.
//  Copyright © 2019 Tourus. All rights reserved.
//

import Foundation
import UIKit

class Interaction {
    var id:String = ""
    var isDeleted:Int = 0
    var type:InteractionType
    var text:String
    var options:[Option]
    var category:String = ""
    var lastUpdate:Double
    var place:Place? = nil
    
    init(_ type:InteractionType, _ text:String, _ options:[Option], _ place:Place? = nil) {
        self.type = type
        self.text = text
        self.options = options
        self.place = place
        lastUpdate = 0
    }
    
    init(_ id:String, _ isDeleted:Int, _ type:String, _ text:String, _ options:[Option], _ category:String, _ lastUpdate:Double, _ place:Place? = nil) {
        self.id = id
        self.isDeleted = isDeleted
        self.type = InteractionType(rawValue: type) ?? .question
        self.text = text
        self.options = options
        self.category = category
        self.lastUpdate = lastUpdate
        self.place = place
    }
    
    init(_id:String, json:[String:Any]) {
        id = _id
        isDeleted = json["isDeleted"] as? Int ?? 0
        type = InteractionType(rawValue: json["type"] as! String) ?? InteractionType.question
        text = json["text"] as! String
        category = json["category"] as! String
        options = [Option]()
        
        let _lastUpdate = json["lastUpdate"] as! Double?
        if(_lastUpdate != nil) {
            lastUpdate = _lastUpdate!
        }
        else {
            lastUpdate = 0
        }
        
        //setting options
        if json.keys.contains("options") {
            let jsonOptions = json["options"] as? [String:Any]
            if jsonOptions != nil {
                jsonToOptions(jsonOptions!)
            }
        }
    }
    
    func addAdditionalOption(_ category:String, _ id:String) {
        let maniCategory = category.replacingOccurrences(of: "_", with: " ").capitalized + "?"
        let option = Interaction.Option(.additional, maniCategory, id)
        
        options.append(option)
    }
    
    func toJson() -> [String:Any] {
        var json = [String:Any]()
        
        json["isDeleted"] = isDeleted
        json["type"] = type.rawValue
        json["text"] = text
        json["category"] = category
        json["options"] = optionsToJson()
        json["lastUpdate"] = lastUpdate

        return json
    }
    
    private func optionsToJson() -> [String:Any] {
        var array:[String:Any] = [String:Any]()
        
        for option in options {
            array[option.type.rawValue] = option.toJson()
        }
        
        return array
    }
    
    private func jsonToOptions(_ jsonOptions:[String:Any]) {
        for option in jsonOptions {
            options.append(Option(option.key, option.value as! [String:Any]))
        }
    }
    
    class Option {
        var id:String = ""
        var type:OptionType
        var text:String
        
        init(_ type:OptionType, _ text:String, _ id:String = "") {
            self.type = type
            self.text = text
            self.id = id

            checkTextEmpty()
        }
        
        init(_ type:String, _ text:String) {
            self.type = OptionType(rawValue: type) ?? .neutral
            self.text = text
            
             checkTextEmpty()
        }
        
        init(_id:String, _ type:String, _ text:String) {
            id = _id
            self.type = OptionType(rawValue: type) ?? .neutral
            self.text = text
            
            checkTextEmpty()
        }

        init(_ type:String, _ details:[String:Any]) {
            self.type = OptionType(rawValue: type) ?? .neutral
            self.text = details["text"] as! String
        }
        
        func toJson() -> [String:Any] {
            var option:[String:Any] = [String:Any]()
            
            option["text"] = self.text
            
            return option
        }
        
        func toString() -> String {
            return String(format: "%@||%@", type.rawValue, text)
        }
        
        private func checkTextEmpty() {
            if self.text == "" {
                self.text = type.defaultString
            }
        }
    }
}

enum InteractionType : String {
    case question
    case info
    case suggestion
}

enum OptionType : String {
    case accept
    case decline
    case negative
    case neutral
    case opinionless
    case additional
    
    var color: UIColor {
        switch self {
        case .accept:
            return .acceptColor
        case .decline:
            return .declineColor
        case .negative:
            return .negativeColor
        case .neutral:
            return .neutralColor
        case .opinionless:
            return .opinionlessColor
        case .additional:
             return .additionalColor
        }
    }
    
    var lightColor: UIColor {
        switch self {
        case .accept:
            return .acceptLightColor
        case .decline:
                return .declineLightColor
        case .negative:
            return .negativeLightColor
        case .neutral:
            return .neutralLightColor
        case .opinionless:
            return .opinionlessLightColor
        case .additional:
            return .additionalLightColor
        }
    }
    
    var value : Double {
        switch self {
        case .accept:
            return 10
        case .decline:
            return -1
        case .negative:
            return -10
        case .neutral:
            return 1
        case .opinionless:
            return 1
        case .additional:
            return 1
        }
    }
    
    var defaultString : String {
        switch self {
        case .accept:
            return "Ok"
        case .decline:
            return "No"
        case .negative:
            return "Not at all"
        case .neutral:
            return "Whateve"
        case .opinionless:
            return "I don't care"
        case .additional:
            return "Something else?"
        }
    }
}
