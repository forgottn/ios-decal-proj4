//
//  Setting.swift
//  FGCNetwork
//
//  Created by Peter Duong on 11/24/15.
//  Copyright © 2015 Peter Duong. All rights reserved.
//

import Foundation

class Setting {
    var title : String!
    var desc : String!
    var inputString : String!
    var inputType : String!
    var tableArray: [String]!
    var parseTitle: String!
    
    var tagToType: [Int: String] = [1: "text", 2: "table", 3: "date"]
    
    var descriptons: [String: String] = [
        "Name": "This is how you appear on the FGC Network",
        "Birthday": "This birth date is used to calculate your age",
        "Region": "This is what others see as your region",
        "Gamertag": "This is the gamertag you use in this game",
        "Main Character": "This is the main character you use in this game"
    ]
    
    var titleToParse: [String: String] = [
        "Name": "fullName",
        "Birthday": "birthday",
        "Region": "region",
        "Gamertag": "gamertag",
        "Main Character": "character"
    ]
    
    init(title: String, input: String, inputType : Int, array: [String]) {
        self.title = title
        self.desc = descriptons[title]
        self.parseTitle = titleToParse[title]
        self.inputType = tagToType[inputType]
        self.inputString = input
        self.tableArray = array
        
    }
}
