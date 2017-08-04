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

func randomString(length: Int) -> String {
    
    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let len = UInt32(letters.length)
    
    var randomString = ""
    
    for _ in 0 ..< length {
        let rand = arc4random_uniform(len)
        var nextChar = letters.character(at: Int(rand))
        randomString += NSString(characters: &nextChar, length: 1) as String
    }
    
    return randomString
}


func addLessonName(drop:Droplet, familyId:String, lang:String) throws -> JSON {
    
     let lessons = try lesson.makeQuery().filter("familyId", .equals, familyId).all()
    
     var lessonList = [JSON]()
     for lesson in lessons {
        var lessonItem = JSON()
        try lessonItem = lesson.makeJSON()
        try lessonItem.set("Lesson",drop.config["lessons",lesson.lessonId,lang])
        lessonList.append(lessonItem)
        
    }
    
    return try lessonList.makeJSON()
}


