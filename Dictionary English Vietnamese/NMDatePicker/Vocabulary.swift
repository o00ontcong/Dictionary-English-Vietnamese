//
//  Vocabulary.swift
//  Dictionary English Vietnamese
//
//  Created by MAC on 18/08/2016.
//  Copyright © 2016 o00ontcong. All rights reserved.
//

import Foundation

class Vocabulary{
    var id : String
    var day : String
    var english : String
    var vietnamese : String
    init(ID: String, DAY: String, ENGLISH: String, VIETNAMESE: String){
        self.id = ID
        self.day = DAY
        self.english = ENGLISH
        self.vietnamese = VIETNAMESE
    }
}
