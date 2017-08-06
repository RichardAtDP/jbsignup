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
    var CASL: String?
    var printKey: String
    var street: String
    var appartment: String?
    var city: String
    var postcode: String
    var homephone: String?
    var cellphone: String?
    var emergencyContact: String?
    var how_hear: String?
    var photos: String?
    var lang:String?
    
    let storage = Storage()
    
    init(email:String, CASL:String?, street:String, appartment:String?, city:String, postcode:String, homephone:String?, cellphone:String?, emergencyContact:String?, how_hear:String?, photos:String?, lang:String?) throws {
        
        self.email = email
        self.CASL = CASL
        self.printKey = randomString(length: 24)
        self.street = street
        self.appartment = appartment
        self.city = city
        self.postcode = postcode
        self.homephone = homephone
        self.cellphone = cellphone
        self.emergencyContact = emergencyContact
        self.how_hear = how_hear
        self.photos = photos
        self.lang = lang

    }
    
    
    init(row: Row) throws {
        email = try row.get("email")
        CASL = try row.get("CASL")
        printKey = try row.get("printKey")
        street = try row.get("street")
        appartment = try row.get("appartment")
        city = try row.get("city")
        postcode = try row.get("postcode")
        homephone = try row.get("homephone")
        cellphone = try row.get("cellphone")
        emergencyContact = try row.get("emergencyContact")
        how_hear = try row.get("how_hear")
        photos = try row.get("photos")
        photos = try row.get("lang")
        
    }
    
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("email", email)
        try row.set("CASL", CASL)
        try row.set("printKey", printKey)
        try row.set("street", street)
        try row.set("appartment", appartment)
        try row.set("city", city)
        try row.set("postcode", postcode)
        try row.set("homephone", homephone)
        try row.set("cellphone", cellphone)
        try row.set("emergencyContact", emergencyContact)
        try row.set("how_hear", how_hear)
        try row.set("photos", photos)
        try row.set("lang", lang)
        
        return row
        
    }
    
}


extension family: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { family in
            family.id()
            family.string("email")
            family.string("CASL",optional:true)
            family.string("printKey")
            family.string("street")
            family.string("appartment",optional:true)
            family.string("city")
            family.string("postcode")
            family.string("homephone",optional:true)
            family.string("cellphone",optional:true)
            family.string("emergencyContact",optional:true)
            family.string("how_hear",optional:true)
            family.string("photos",optional:true)
            family.string("lang",optional:true)
   
        }
        
        
        
    }
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}


extension family: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            email: json.get("email"),
            CASL: json.get("CASL"),
            street:  json.get("street"),
            appartment:  json.get("appartment"),
            city:  json.get("city"),
            postcode:  json.get("postcode"),
            homephone:  json.get("homephone"),
            cellphone:  json.get("cellphone"),
            emergencyContact:  json.get("emergencyContact"),
            how_hear: json.get("how_hear"),
            photos: json.get("photos"),
            lang: json.get("lang")

        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("email", email)
        try json.set("CASL", CASL?.toCheck())
        try json.set("printKey", printKey)
        try json.set("street", street)
        try json.set("appartment", appartment)
        try json.set("city", city)
        try json.set("postcode", postcode)
        try json.set("homephone", homephone)
        try json.set("cellphone", cellphone)
        try json.set("emergencyContact", emergencyContact)
        try json.set("how_hear", how_hear)
        try json.set("photos", photos?.toCheck())
        try json.set("lang",lang)
        
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
