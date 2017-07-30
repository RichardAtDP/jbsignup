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
    var frequency: Int
    var familyId: String
    var dancerId: String
    
    let storage = Storage()
    
    init(lessonId:String, frequency:Int, familyId:String, dancerId:String) throws {
        
        self.lessonId = lessonId
        self.frequency = frequency
        self.familyId = familyId
        self.dancerId = dancerId
        
    }
    
    
    init(row: Row) throws {
        lessonId = try row.get("lessonId")
        frequency = try row.get("frequency")
        familyId = try row.get("familyId")
        dancerId = try row.get("dancerId")
        
    }
    
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("lessonId", lessonId)
        try row.set("frequency", frequency)
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
            lesson.int("frequency")
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
            frequency: json.get("frequency"),
            familyId: json.get("familyId"),
            dancerId: json.get("dancerId")
            
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("lessonId", lessonId)
        try json.set("frequency", frequency)
        try json.set("familyId", familyId)
        try json.set("dancerId", dancerId)
        
        
        return json
    }
}

extension lesson: Timestampable { }

extension lesson: ResponseRepresentable { }
