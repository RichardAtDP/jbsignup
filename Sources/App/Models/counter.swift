//
//  counters.swift
//  jbsignup
//
//  Created by Richard on 2017-08-14.
//

import Foundation
import Vapor
import FluentProvider


final class counter: Model {
    
    var objectId: String
    var counter: Int
    
    let storage = Storage()
    
    init(objectId:String, counter:Int) throws {
        
        self.objectId = objectId
        self.counter = counter

        
    }
    
    
    init(row: Row) throws {
        objectId = try row.get("objectId")
        counter = try row.get("counter")
  
    }
    
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("objectId", objectId)
        try row.set("counter", counter)

        return row
        
    }
    
}


extension counter: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { counter in
            counter.id()
            counter.string("objectId")
            counter.int("counter")

            
        }
        
        
        
    }
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}


extension counter: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            objectId: json.get("objectId"),
            counter: json.get("counter")
            
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("objectId", objectId)
        try json.set("counter", counter)

        return json
    }
}

extension counter: Timestampable { }

extension counter: ResponseRepresentable { }
