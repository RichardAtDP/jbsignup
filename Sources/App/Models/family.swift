//
//  family.swift
//  jbsignup
//
//  Created by Richard on 2017-07-29.
//

import Foundation
import Vapor
import FluentProvider

final class family: Model {
    
    var email: String
    
    let storage = Storage()
    
    init(email:String) throws {
        
        self.email = email

    }
    
    
    init(row: Row) throws {
        email = try row.get("email")
        
    }
    
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("email", email)

        
        return row
        
    }
    
}


extension family: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { family in
            family.id()
            family.string("email")

            
            
            
            
        }
        
        
        
    }
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}


extension family: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            email: json.get("email")

        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("email", email)

        
        return json
    }
}

extension family: Timestampable { }

extension family: ResponseRepresentable { }
