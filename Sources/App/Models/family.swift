//
//  family.swift
//  jbsignup
//
//  Created by Richard on 2017-07-29.
//

import Foundation
import Vapor
import FluentProvider
import SMTP

final class family: Model {
    
    var email: String
    var printKey: String
    
    let storage = Storage()
    
    init(email:String) throws {
        
        self.email = email
        self.printKey = randomString(length: 24)

    }
    
    
    init(row: Row) throws {
        email = try row.get("email")
        printKey = try row.get("printKey")
        
    }
    
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("email", email)
        try row.set("printKey", printKey)
        
        return row
        
    }
    
}


extension family: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { family in
            family.id()
            family.string("email")
            family.string("printKey")

            
            
            
            
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
        try json.set("printKey", printKey)
        
        return json
    }
}

extension family: Timestampable { }

extension family: ResponseRepresentable { }

func sendEmail(familyId:String, Template:String, drop:Droplet) throws {
    
    var subject = ""
    var body = ""
    
    let Family = try family.find(familyId)
    
    if Template == "PRINT" {
        
        body = "Thank you for sending this email. You can retrieve your stuff here: http://0.0.0.0:8080/print/\(Family!.printKey)"
        
        subject = "Your Inscription"
    }
    

    if Template == "EMAIL_EXISTS" {
        
        body = "You can retrieve your inscription here: http://0.0.0.0:8080/restart/\(Family!.printKey)"
        
        subject = "Your Inscription to Junior Ballet's 2017 Fall Season"
    }
    
    let email = Email(from:"info@junior-ballet.com", to: Family!.email, subject: subject, body: body)
    try drop.mail.send(email)
}
