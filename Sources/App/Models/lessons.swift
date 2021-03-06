//
//  lessons.swift
//  jbsignup
//
//  Created by Richard on 2017-07-30.
//

import Foundation
import Vapor
import FluentProvider

final class lesson: Model {
    
    var lessonId: String
    var familyId: String
    var dancerId: String
    
    let storage = Storage()
    
    init(lessonId:String, familyId:String, dancerId:String) throws {
        
        self.lessonId = lessonId
        self.familyId = familyId
        self.dancerId = dancerId
        
    }
    
    
    init(row: Row) throws {
        lessonId = try row.get("lessonId")
        familyId = try row.get("familyId")
        dancerId = try row.get("dancerId")
        
    }
    
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("lessonId", lessonId)
        try row.set("familyId", familyId)
        try row.set("dancerId", dancerId)
        
        
        return row
        
    }
    
}


extension lesson: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { lesson in
            lesson.id()
            lesson.string("lessonId")
            lesson.string("familyId")
            lesson.string("dancerId")
            
        }
        
        
        
    }
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}


extension lesson: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            lessonId: json.get("lessonId"),
            familyId: json.get("familyId"),
            dancerId: json.get("dancerId")
            
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("lessonId", lessonId)
        try json.set("familyId", familyId)
        try json.set("dancerId", dancerId)
        
        
        
        return json
    }
}

extension lesson: Timestampable { }

extension lesson: ResponseRepresentable { }


func saveLesson(proData:Content, familyid:String) throws {
    
    // Swift freaks if it receives a string rather than an array, so make arrays.
    var lessonList = [Node]()
    var frequency = [Node]()
    var dancerId = [Node]()
    if proData["lesson"]!.array == nil {
        lessonList = [proData["lesson"]!.string!.makeNode(in: nil)]
        dancerId = [proData["dancer"]!.string!.makeNode(in: nil)]
        
    } else {
        lessonList = proData["lesson"]!.array!
        dancerId = proData["dancer"]!.array!
    }
    
    // Go through each item and save or update
    var i = 0
    for chosenLesson in lessonList {
        
            
            let query = try lesson.makeQuery()
            try query.filter("lessonId",.equals,chosenLesson.string!)
            try query.filter("dancerId",.equals,dancerId[i].string!)
            try query.filter("familyId",.equals,familyid)
            
            if try query.count() == 0 {
                // New
                let Lesson = try lesson(lessonId:chosenLesson.string!, familyId:familyid, dancerId:dancerId[i].string!)
                
                try Lesson.save()
            } else {
                // Update existing
                let Lesson = try lesson.find(query.first()?.id)
                Lesson?.lessonId = chosenLesson.string!
                Lesson?.dancerId = dancerId[i].string!
                Lesson?.familyId = familyid
                
                try Lesson?.save()
            }
            
        
        
        
        
        i += 1
    }
    
    
}
