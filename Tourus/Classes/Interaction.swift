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
    var type:InteractionType
    var text:String
    var options:[Option]
    
    init(_ type:InteractionType, _ text:String, _ options:[Option]) {
        self.type = type
        self.text = text
        self.options = options
    }
    
    class Option {
        var type:OptionType
        var text:String
        
        init(_ type:OptionType, _ text:String) {
            self.type = type
            self.text = text
        }
    }
}

enum InteractionType {
    case question
    case info
    case suggestion
}

enum OptionType {
    case positive
    case negative
    case neutral
    case opinionless
    
    var color: UIColor {
        switch self {
        case .positive:
            return .positiveColor
        case .negative:
            return .negativeColor
        case .neutral:
            return .neutralColor
        case .opinionless:
            return .opinionlessColor
        }
    }
    
    var lightColor: UIColor {
        switch self {
        case .positive:
            return .positiveLightColor
        case .negative:
            return .negativeLightColor
        case .neutral:
            return .neutralLightColor
        case .opinionless:
            return .opinionlessLightColor
        }
    }
}


