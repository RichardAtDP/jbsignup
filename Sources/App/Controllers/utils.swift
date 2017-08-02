//
//  utils.swift
//  jbsignup
//
//  Created by Richard on 2017-07-29.
//

import Foundation
import Vapor
import FluentProvider


extension String {
  
    func toDate () -> Date {
    
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-DD"

            return dateFormatter.date(from: self)!
    }

}

extension Date {
    
    func ISODate () -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-DD"
        
        return dateFormatter.string(from: self)
        
    }
    
    
}

extension String
{
    var isNumeric: Bool
    {
        let range = self.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted)
        return (range == nil)
    }
}


func lessonList(_ info:Droplet) throws -> Array<JSON> {
    
    let lessons = info.config["lessons","lessons"]!.array
    var selectLesson = [JSON]()
    for lesson in lessons! {
        var json = JSON()
        try json.set("key",lesson.string!)
        try json.set("readable",info.config["lessons",lesson.string!,"en"]!.string!)
        try json.set("status","")
        selectLesson.append(json)
    }
    return selectLesson
}



